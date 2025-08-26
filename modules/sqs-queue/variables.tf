variable "name" {
  description = "Vollständiger Name der SQS-Queue"
  type        = string
}

variable "create_dlq" {
  description = "Erzeuge eine Dead-Letter-Queue <name>-dlq und setze Redrive Policy"
  type        = bool
  default     = true
}

variable "visibility_timeout_seconds" {
  description = "Sichtbarkeits-Timeout je Nachricht (Sekunden)"
  type        = number
  default     = 60
}

variable "max_receive_count" {
  description = "Maximale Anzahl Zustellungen vor DLQ (nur wenn create_dlq=true)"
  type        = number
  default     = 5
}

variable "message_retention_seconds" {
  description = "Aufbewahrungsdauer für Nachrichten (Sekunden), Standard 4 Tage"
  type        = number
  default     = 345600
}

variable "tags" {
  description = "Zusätzliche Tags; werden mit Provider default_tags gemerged"
  type        = map(string)
  default     = {}
}
