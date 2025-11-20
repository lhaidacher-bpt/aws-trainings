variable "name" {
  description = "Lambda-Funktionsname und Basis für die IAM-Rolle"
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

variable "sqs_read_arn" {
  description = "ARN der SQS-Queue, aus der Events konsumiert werden"
  type        = string
}

variable "sqs_send_arn" {
  description = "ARN der SQS-Queue, in die Events gespeichert werden"
  type        = string
  default     = null
}

variable "s3_put_arns" {
  description = "S3-ARNs für PutObject"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Zusätzliche Tags für Lambda und IAM-Rolle; wird mit default_tags gemerged"
  type        = map(string)
  default     = {}
}