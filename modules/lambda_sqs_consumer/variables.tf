variable "name" {
  description = "Lambda-Funktionsname und Basis für die IAM-Rolle"
  type        = string
}

variable "queue_arn" {
  description = "ARN der SQS-Queue, aus der Events konsumiert werden"
  type        = string
}

variable "code_dir" {
  description = "Pfad zum Code-Verzeichnis (wird als ZIP via archive_file gepackt)"
  type        = string
}

variable "env" {
  description = "Umgebungsvariablen der Funktion (z. B. LANDING_BUCKET, SPLITTER_QUEUE_URL)"
  type        = map(string)
  default     = {}
}

variable "batch_size" {
  description = "Maximale Anzahl Records pro Aufruf (SQS → Lambda)"
  type        = number
  default     = 10
}

variable "batch_window_seconds" {
  description = "Maximales Sammelzeitfenster in Sekunden"
  type        = number
  default     = 5
}

variable "runtime" {
  description = "Lambda-Runtime"
  type        = string
  default     = "nodejs22.x"
}

variable "architectures" {
  description = "CPU-Architekturen (z. B. arm64)"
  type        = list(string)
  default     = ["arm64"]
}

variable "s3_put_object_arns" {
  description = "Liste von S3-Bucket-ARNs, auf die PutObject erlaubt sein soll"
  type        = list(string)
  default     = []
}

variable "sqs_send_arns" {
  description = "Liste von SQS-Queue-ARNs, auf die SendMessage/SendMessageBatch erlaubt sein soll"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Zusätzliche Tags für Lambda und IAM-Rolle; wird mit default_tags gemerged"
  type        = map(string)
  default     = {}
}