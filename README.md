# AWS Trainings

Dieses Repository begleitet eine praxisorientierte Lernreihe. Ziel ist es, in kurzen Micro-Trainings (90 Min) und
ergänzenden Self-paced-Abschnitten wiederverwendbare Infrastruktur mit Terraform in AWS aufzubauen – Schritt für Schritt
bis zu einer produktionsnahen Integration-Layer.

## Zielbild

![Zielbild: Integration Layer](docs/target-architecture.png)

## Trainings

1. Training – Terraform & S3: Terraform-Workspace und S3-Buckets mit Best-Practices
2. Training – Lambda & SQS: SQS-Queue, Lambda-Trigger und rudimentäre Verarbeitung
3. Training - Step Functions & Monitoring: Orchestrierung und CloudWatch/Costs/Observability-Basics
4. Training - IAM & Externe API Push via Lambda: Berechtigungen und Push zu Salesforce
5. Training - tbd: (z.B.) CI/CD für Terraform, Replikation/DR, Storage Lens, Data Events

### Trainingsformat

1. Einführung (≤ 10 min): Ziel, Scope, Theorie-Kurzüberblick
2. Hands-on (≈ 45 min): eigenständige Umsetzung
3. Review & Diskussion (≈ 30 min): Lösungen, Best Practices, Ausblick

## Voraussetzung

- Terraform CLI ≥ 1.5
- AWS CLI konfiguriert
- Editor mit HCL-Unterstützung

## Quickstart

```shell
# 1) Repo klonen & in Trainings-Branch wechseln
git clone https://github.com/lhaidacher-bpt/aws-trainings.git
cd aws-trainings
git checkout <TRAINGS_BRANCH>

# 2) Lokale Variablen vorbereiten
cp docs/terraform.tfvars.example terraform.tfvars 
# Werte in terraform.tfvars anpassen

# 3) Terraform-Workflow
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```