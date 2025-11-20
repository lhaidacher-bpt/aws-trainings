# AWS Trainings

Dieses Repository begleitet eine praxisorientierte Lernreihe. Ziel ist es, in kurzen Micro-Trainings (90 Min) und
ergänzenden Self-paced-Abschnitten wiederverwendbare Infrastruktur mit Terraform in AWS aufzubauen – Schritt für Schritt
bis zu einer produktionsnahen Integration-Layer.

## Einführung

### Zielbild

![Zielbild: Integration Layer](docs/architecture/target-architecture.png)

### Trainings

1. Training – Terraform & S3: Terraform-Workspace und S3-Buckets mit Best-Practices
2. Training – Lambda & SQS: SQS-Queue, Lambda-Trigger und rudimentäre Verarbeitung
3. Training - Step Functions & Monitoring: Orchestrierung und CloudWatch/Costs/Observability-Basics
4. Training - EventBridge & AppFlow
5. Training - tbd: (z.B.) CI/CD für Terraform, Replikation/DR, Storage Lens, Data Events

#### Trainingsformat

1. Einführung (≤ 10 min): Ziel, Scope, Theorie-Kurzüberblick
2. Hands-on (≈ 45 min): eigenständige Umsetzung
3. Review & Diskussion (≈ 30 min): Lösungen, Best Practices, Ausblick

### Voraussetzungen

- Terraform CLI ≥ 1.5
- AWS CLI konfiguriert
- Editor mit HCL-Unterstützung

### Quickstart

```shell
# 1) Repo klonen & in Trainings-Branch wechseln
git clone https://github.com/lhaidacher-bpt/aws-trainings.git
cd aws-trainings
git checkout <TRAININGS_BRANCH>

# 2) Lokale Variablen vorbereiten
cp docs/samples/terraform.tfvars.example terraform.tfvars 
# Werte in terraform.tfvars anpassen

# 3) Terraform-Workflow
terraform init
terraform fmt -recursive
terraform validate
terraform plan -refresh=false
terraform apply
```

---

## 1. Training: Terraform & S3

**Ziel**: Terraform-Workspace initialisieren und drei S3-Buckets (logs, landing, staging) mit soliden Defaults erstellen

### Lernziel

- Terraform-Workflow sicher anwenden: fmt → validate → plan (→ apply)
- Ein minimales, wiederverwendbares S3-Bucket-Modul erstellen
- Best Practices: Block Public Access, Versioning, Default Encryption (SSE-S3), Lifecycle

### Aufgaben

1. Workspace vorbereiten (init & .tfvars kopieren)
2. Terraform Modul(e) bauen
    - Resources: [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
    - Inputs: `bucket_name`, `enable_versioning`, `encryption_type`, `block_public_access`, `lifecycle`
    - BucketOwnerEnforced ist aktiviert
    - Outputs: `bucket_name`, `bucket_arn`
3. Drei Instanzen anlegen
    - logs: Transition → nach 30 Tagen zu INTELLIGENT_TIERING, Expire 365
    - landing: Expire 180, Abort incomplete MPU 7
    - staging: Transition → 60 Tage zu INTELLIGENT_TIERING, Expire 730
    - Einheitliches Naming `<$PROJECT_NAME>-<$PARTICIPANT>-<$ZWECK>`
4. Validate & Plan
    - Formatierung
    - Validierung
    - Planung

### Definition of Done

- 3 Buckets existieren mit Object Ownership und Policies
- `terraform fmt/validate/plan` ohne Fehler
- `outputs` listen die drei Bucket-Namen

---

## 2. Training: SQS & Lambda

**Ziel**: Eingehende Nachrichten über eine SQS Queues und Lambdas verarbeiten und aufbereiten

### Lernziele

- SQS zu Lambda Event Source Mapping (Batching, Partial Batch Failure)
- Least-Privilege IAM für S3 PutObject, SQS Receive/Delete/Send
- Node.js 22 Lambda (AWS SDK v3, keine zusätzlichen Packages)

### Aufgaben

1. Workspace vorbereiten (init & .tfvars kopieren)
2. Queues anlegen (jeweils mit DLQ & Redrive Policy)
    - Landing
    - Splitter
3. Lambda „Extract“ (SQS Landing → S3 Landing → SQS Splitter)
    - Event Source Mapping konfigurieren (Batching, Partial Batch Failure)
    - Nachricht als NDJSON im S3-Landing-Bucket ablegen: `s3://<LANDING_BUCKET>/raw-message/<messageId>.ndjson`
    - Audit-Drop als JSON im Logs-Bucket ablegen: `s3://<LOGS_BUCKET>/landing-audit/<messageId>.json`
    - Original-Nachricht an SQS-Splitter-Queue weiterleiten
4. Lambda „Splitter“ (SQS Splitter → S3 Staging)
    - Event Source Mapping konfigurieren
    - events[] als einzelne JSON-Dateien im S3-Staging-Bucket
      speichern: `s3://<STAGING_BUCKET>/raw-events/<eventId>.json`
5. Validate & Plan
    - Formatierung
    - Validierung
    - Planung

### Definition of Done

- Eine Nachricht in der Landing Queue erzeugt eine NDJSON-Datei unter `raw-message/<messageId>.ndjson`
- Audit-Eintrag wird unter `landing-audit/<messageId>.json` erstellt
- Nachricht wird an Splitter Queue weitergeleitet
- Splitter legt pro Event eine JSON-Datei unter `raw-events/<eventId>.json` ab
- Partial Batch Failure ist aktiv und funktioniert
- DLQs bleiben leer bei gültigem Input
- `terraform fmt/validate/plan` ohne Fehler

---

## 3. Training: Step-Function

- **Ziel:** Eine "Standard" Step Function orchestriert die Verarbeitung eines einzelnen Events aus dem S3 Staging
  Bucket.

### Step-Function Architektur

<img src="docs/architecture/step-function.png" alt="Step Function" style="width:400px;"/>

### Lernziele

- Grundbausteine: Task (Lambda), AWS SDK Integrations (S3 Put/Delete)
- Parameters, OutputPath/ResultPath, ResultSelector, Intrinsics (States.Format, States.JsonToString,
  States.Base64Encode)
- (Optional) Retry auf Tasks

### Aufgaben

1. Workspace vorbereiten (init & .tfvars kopieren)
2. Lambda „Transform“
    - Implementieren der Lambda-Funktionalität in `/lambda/transform/index.mjs`
        - Einzelnes Event aus `s3://<STAGING_BUCKET>/raw-events/<eventId>.json` lesen
        - Roh-Event nach vorgegeben Schema transformieren
        - Transformiertes Event inklusive benötigte Parameter an nächsten Step übergeben
    - Implementieren der Terraform-Definition in `/modules/lambda_sf_tranform/main.tf`
        - Umsetzen der To-dos
        - Lambda-Terraform ist ausgelagert; Vorteil: Transformierung kann ausgetauscht werden, ohne StepFunction ändern
          zu müssen
3. Step-Function (Definition)
    - Implementieren laut Architektur - Bausteine: Transform-Lambda, S3-Put-Object und S3-Delete-Object
    - *Achtung*: auf Benennung der Return-Parameter achten
    - _lambda:invoke_ Parameter
        - FunctionName: `${var.transform_lambda_arn}`
        - Payload: `$`
    - _s3:putObject_ Parameter
        - Bucket: `$.bucket`
        - Key: `States.Format('transformed/id={}/{}.json', $.transformedId, $.millis)`
        - Body: `$.event`
        - ContentType: `application/json`
    - _s3:deleteObject_ Parameter
        - Bucket: `$.bucket`
        - Key: `$.rawId`
4. Anpassen der `main.tf`: Lambda und Step-Function hinzufügen
5. Validate & Plan
    - Formatierung
    - Validierung
    - Planung

### Definition of Done

- Eine Ausführung mit Input { "eventId": "<EVENT_ID>" }
    - legt genau eine Datei unter transformed/<EVENT_ID>/<millis>.json an (inkl. korrektes Mapping),
    - löscht das ursprüngliche Raw-Objekt raw-events/<EVENT_ID>.json.
- Der State Output enthält putResult.etag (durch ResultSelector) und weiterhin bucket/rawKey.
- terraform fmt/validate/plan ohne Fehler; Deployment erfolgreich.

---

## 4. Training: Automatisierung – EventBridge & AppFlow (Salesforce)

**Ziel**

1) EventBridge startet bei jedem neuen Objekt unter `s3://<STAGING_BUCKET>/raw-events/` automatisch die Step Function
   aus Training #3 (pro Objekt eine Ausführung).
2) AppFlow synchronisiert die Inhalte aus `s3://<STAGING_BUCKET>/transformed/` jede Minute nach Salesforce (Lead) –
   gesteuert durch den AppFlow‑eigenen Scheduler.

### Architektur (Kontext)

- **Bisher (T#3):** `S3 (raw-events); (manuelles triggern) Step Function → S3 (transformed)`
- **Neu in T#4:**
    - `S3 (raw-events) ─ EventBridge Rule -> Step Function (auto)`
    - `S3 (transformed) ─ AppFlow (Schedule: every 1 min) -> Salesforce (Lead)`

### Lernziele

- EventBridge Event Pattern für S3 ObjectCreated (Prefix‑Filter, Rule/Target‑Role)
- Step Functions StartExecution per EventBridge (Input‑Transformer `{ bucket, key }`)
- AppFlow S3 -> Salesforce (Flow, Field‑Mapping, Scheduled Trigger)

### Voraussetzungen

- Salesforce Connector Profile existiert bereits: `fosil-training-salesforce-profile`
- Salesforce Ziel‑Objekt: Lead
    - id -> CustomerPartnerNumber__c
    - vorname -> FirstName
    - nachname -> LastName
- Verwenden der existierenden `fosil-training-admin-role` Rolle

### Aufgaben

1) `terraform.tfvars` aktualisieren (wichtig!)
   ```hcl
   # EventBridge → Step Functions
   iam_admin_role_arn         = "<ARN der Trainings-Rolle>"
   sf_connector_profile_name  = "<Name von Salesforce Profile>"
   ```

2) S3 -> EventBridge aktivieren (Bucket‑Toggle)
    - In Terraform sicherstellen, dass am Staging‑Bucket EventBridge aktiviert ist:
      ```hcl
      resource "aws_s3_bucket_notification" "staging_eventbridge" {}
      ```

3) EventBridge Rule: `raw-events/` -> Step Function
    - Modul anlegen, das eine Rule mit Prefix‑Filter erstellt und die State Machine startet.
    - Kernpunkte (vereinfacht, sinngemäß):
        - Rule (enabled) – Pattern:
          ```json
          {
            "source": ["aws.s3"],
            "detail-type": ["Object Created"],
            "detail": {
              "bucket": { "name": ["<STAGING_BUCKET>"] },
              "object" : { "key" : [{ "wildcard" : "${var.prefix}/*.json" }] }
            }
          }
          ```
        - Target: Step Functions mit Input‑Transformer
          ```json
          { "bucket": "<bucket>", "key": "<key>" }
          ```

4) AppFlow: S3 (transformed/) -> Salesforce (Lead), Schedule jede Minute
    - trigger_type: Scheduled
    - Quelle: S3
        - Bucket: `<STAGING_BUCKET>`
        - Prefix: `transformed`
        - Typ: `JSON`
    - Ziel: Salesforce (Connector Profile **`fosil-training-salesforce-profile`**)
        - Object: **Lead**
        - Write Operation: **UPSERT** (Upsert‑Id: `CustomerPartnerNumber__c`)
    - Field Mapping
        - `id` → `CustomerPartnerNumber__c`
        - `vorname` → `FirstName`
        - `nachname` → `LastName`
    - Schedule: `rate(1 minute)` (AppFlow‑Scheduler)

5) **Validate & Plan**
    - `terraform fmt -recursive`
    - `terraform validate`
    - `terraform plan` (→ `apply`)

### Definition of Done

- EventBridge → Step Functions: Upload von `raw-events/<id>.json` im Staging‑Bucket startet genau eine
  State‑Machine‑Ausführung.
- AppFlow (Lead‑Sync)
    - Der Flow läuft jede Minute automatisch und upsertet nach **Lead**:
    - AppFlow‑Run‑Historie zeigt Success, keine Failed Records.

# 5. Training: IAM – Least-Privilege für unsere Lambdas

**Ziel**

Die bisherige **Admin-Rolle** wird ersetzt. Für die Lambdas **Extract** und **Splitter** erstellen wir je eine **eigene
Execution-Role** (Trust für `lambda.amazonaws.com`) mit **minimalen** Berechtigungen (Logs, SQS, S3). Funktionales
Verhalten bleibt unverändert. Zusätzlich aktivieren wir **SSE‑KMS** für den **Landing‑Bucket** mittels **Customer
Managed Key (CMK)** und vergeben **minimal nötige KMS‑Rechte** ausschließlich an die **Extract‑Lambda**.

---

## Architektur (Kontext)

- **Unverändert:** SQS (Landing/Splitter), S3 (Logs/Landing/Staging), Step Functions, EventBridge, AppFlow.
- **Neu in T#5:** Je Lambda eine **Least-Privilege Execution-Role** (keine Admin-Rolle mehr).

---

## Lernziele

- Trust-Policy & `sts:AssumeRole` (warum Lambda Rollen „annimmt“).
- Identity-Policies: **Actions** vs. **Resources** (präzise S3-Prefix-ARNs, SQS-Queue-ARNs).
- Inline-Policies mit `data "aws_iam_policy_document"` (und wann Managed Policies sinnvoll sind).
- Typische Fehlerbilder (AccessDenied), Debug über CloudWatch Logs.
- Grundverständnis KMS: **CMK**, **Key Policy** vs. **IAM Policy**, **Encrypt/GenerateDataKey/Decrypt**.

---

## Voraussetzungen

- Projektstand nach Training #4 (EventBridge + AppFlow) baut erfolgreich.
- SQS- und S3-Ressourcen existieren (Landing, Splitter, Logs, Landing, Staging).

---

## Aufgaben

1) **Vorbereitung**
    - Neuen Branch auschecken (z. B. `training-5-starter`).
    - In `/modules/lambda_sqs_consumer/variables.tf` die Variable **`iam_admin_role_arn` entfernen**.

2) **TODOs im Modul `/modules/lambda_sqs_consumer/main.tf` umsetzen**
    - **Trust-Policy** (Data Source) für `lambda.amazonaws.com` mit `sts:AssumeRole`.
    - **Execution-Role** `aws_iam_role.execution` anlegen (Assume-JSON aus obiger Data Source).
    - **Logs-Policy**
    - **SQS-Policy** Read & Write
    - **S3-Policy**
    - **Lambda an neue Rolle binden**

3) **Root-Module anpassen**
    - **Extract**:
        - `arn:aws:s3:::<landing-bucket>/*`
        - `arn:aws:s3:::<logs-bucket>/*`
        - `sqs_send_arn = <splitter-queue-arn>`
    - **Splitter**: `s3_put_arns` = `arn:aws:s3:::<staging-bucket>/raw-events/*`
    - **Alle Verweise auf `iam_admin_role_arn` entfernen** (Variablen + Aufrufe).

4) OPTIONAL: KMS CMK
   - **CMK (Customer Managed Key) anlegen**
      - Modul `./modules/kms` erstellen oder vorhandenes verwenden
      - **Key Policy** (pragmatisch): Root des Accounts darf alles (für das Training ok!).
   - **Landing‑Bucket auf SSE‑KMS umstellen**
      - In `module "s3_landing"`:
        ```hcl
        encryption_type = "SSE-KMS"
        kms_key_id      = module.kms_landing.key_arn
        ```
      - Keine Änderungen an Logs/Staging (bleiben ohne KMS) → Unterschied ist demonstrierbar.
   - **Extract‑Lambda KMS‑Rechte geben (nur das Nötigste)**
      - In eurem `modules/lambda_sqs_consumer` Aufruf für **Extract**:
         - **unverändert**: `s3_put_arns` mit Landing‑Bucket + Logs‑Prefix.
         - **neu**: `kms_key_arns = [ module.kms_landing.key_arn ]`
           ```hcl
           actions   = ["kms:Encrypt","kms:GenerateDataKey","kms:GenerateDataKeyWithoutPlaintext","kms:DescribeKey"]
           resources = var.kms_key_arns
           ```
      - **Kein `kms:Decrypt`** für Extract nötig, da sie nur **schreibt** (S3 erledigt die Verschlüsselung).

4) **Validate & Plan**
   ```bash
   terraform fmt -recursive
   terraform validate
   terraform plan   # → terraform apply
   ```

---

## Definition of Done

- **Admin-Rolle ist vollständig entfernt.**  
  Beide Lambdas verwenden ihre **eigene Execution-Role**.
- **Extract-Lambda**:
    - Kann von **Landing-Queue** lesen und nach **Landing-Bucket** sowie **Logs-Prefix** schreiben.
    - Kann an **Splitter-Queue** senden.
- **Splitter-Lambda**:
    - Kann von **Splitter-Queue** lesen und nach **Staging/raw-events** schreiben.
- **`terraform validate/plan`** ohne Fehler, **`apply`** erfolgreich.  
  Smoke-Test: Nachricht in Landing-Queue → Dateien erscheinen wie zuvor (Logs/Landing bzw. Staging/raw-events).
- **CMK existiert** (Alias z.B. `alias/train-landing`), Landing‑Bucket nutzt **SSE‑KMS**.

---

## Hinweise & Troubleshooting

- **Rolle wirklich aktiv?** In `aws_lambda_function.this` muss `role = aws_iam_role.execution.arn` stehen.
- **S3-ARNs:** Für **Objekte** immer `arn:aws:s3:::bucket/prefix/*`, nicht nur den Bucket-ARN.
- **SQS-Queue-Policy:** Falls vorhanden, darf sie eure Execution-Role **nicht** aussperren (keine `Deny`-Condition).
- **CloudWatch Logs** zeigen bei `AccessDenied` die **konkrete Action & Resource** → gezielt nachschärfen.

