variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_instance_class" {
  description = "Instance class for RDS (free-tier eligible)"
  type        = string
  default     = "db.t3.micro"
}


variable "storage_type" {
  description = "Storage Type"
  type        = string
  default     = "gp2"
}


variable "engine" {
  description = "RDS Engine"
  type        = string
  default     = "postgres"
}

variable "parameter_group_name" {
  description = "RDS Parameter"
  type        = string
  default     = "default.postgres16"
}


variable "db_instance_identifier" {
  description = "Database Identifier"
  type        = string
  default     = "db-fiap-8soat-team32"
}


variable "db_name" {
  description = "Database Identifier"
  type        = string
  default     = "fiapBackend"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for RDS"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "db_engine_version" {
  description = "The PostgreSQL engine version"
  type        = string
  default     = "16" # Replace with the latest PostgreSQL version available in RDS
}

variable "publicly_accessible" {
  description = "Set to true if the RDS instance should be publicly accessible"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "The number of days to retain backups for"
  type        = number
  default     = 7
}

variable "environment" {
  description = "Environment tag for RDS instance"
  type        = string
  default     = "Dev"
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the RDS instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Allow public access; replace with specific IPs for security
}


variable "tags_name" {
  description = "Tags Name"
  type        = string
  default     = "Fiap8SoatTeam32"
}