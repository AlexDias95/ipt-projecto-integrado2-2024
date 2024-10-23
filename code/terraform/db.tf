resource "aws_db_instance" "ipt_poc_movies_db" {
    allocated_storage    = 20
    storage_type         = "gp3"
    engine               = "postgres"
    engine_version       = "14.13"
    instance_class       = "db.t4g.micro"
    db_name              = "ipt_poc_movies_db"
    username             = "postgres"
    password             = "postgres123"
    parameter_group_name = "default.postgres14"
    publicly_accessible  = true
    skip_final_snapshot  = true
}

resource "aws_db_instance" "ipt_poc_cast_db" {
    allocated_storage    = 20
    storage_type         = "gp3"
    engine               = "postgres"
    engine_version       = "14.13"
    instance_class       = "db.t4g.micro"
    db_name              = "ipt_poc_cast_db"
    username             = "postgres"
    password             = "postgres123"
    parameter_group_name = "default.postgres14"
    publicly_accessible  = true
    skip_final_snapshot  = true
}

resource "local_file" "db_connection_info" {
    content  = <<-EOT
    #IPT PoC Movies DB:
    MOVIE_DB="postgresql://${aws_db_instance.ipt_poc_movies_db.username}:${aws_db_instance.ipt_poc_movies_db.password}@${aws_db_instance.ipt_poc_movies_db.address}:${aws_db_instance.ipt_poc_movies_db.port}/${aws_db_instance.ipt_poc_movies_db.db_name}"

    #IPT PoC Cast DB:
    CAST_DB="postgresql://${aws_db_instance.ipt_poc_cast_db.username}:${aws_db_instance.ipt_poc_cast_db.password}@${aws_db_instance.ipt_poc_cast_db.address}:${aws_db_instance.ipt_poc_cast_db.port}/${aws_db_instance.ipt_poc_cast_db.db_name}"
    EOT
    filename = "../docker/.env"
    file_permission = 644
}