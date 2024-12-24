CREATE DATABASE tinyedu;

\c tinyedu

CREATE SCHEMA school2;

CREATE TABLE school2."student"(
	"student_id" character(8) NOT NULL,
	"first_name" character varying(20),
	"last_name" character varying(20),
	"dob" character(10),
	"gender" character varying(10),
	"adress" character varying,
	"note" character varying,
	"class_id" character varying(4),
	CONSTRAINT pk_student PRIMARY KEY("student_id"),
	CONSTRAINT fk_class FOREIGN  KEY("class_id")
	REFERENCES school2."class"("class_id")
);

CREATE TABLE school2."class"(
	"class_id" character(4) NOT NULL,
	"name" character varying(20),
	"lecturer_id" character(4),
	"monitor_id" character(5), 
	CONSTRAINT pk_class PRIMARY KEY("class_id")
);

CREATE TABLE school2."lecturer"(
	"lecturer_id" character(8) NOT NULL,
	"first_name" character varying,
	"last_name" character varying,
	"dob" character(10),
	"gender" character varying(10),
	"adress" character varying(10),
	"email" character varying(10),
	CONSTRAINT pk_lectr PRIMARY KEY("lecturer_id")
);

ALTER TABLE school2."class"
ADD CONSTRAINT fk_lectr FOREIGN KEY("lecturer_id") 
REFERENCES school2."lecturer"("lecturer_id");






	