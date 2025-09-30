variable "name" {
  description = "Lambda-Funktionsname und Basis für die IAM-Rolle"
  type        = string
}

variable "iam_admin_role_arn" {
  description = "IAM Role ARN für Admin"
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

variable "tags" {
  description = "Zusätzliche Tags für Lambda und IAM-Rolle; wird mit default_tags gemerged"
  type        = map(string)
  default     = {}
}
