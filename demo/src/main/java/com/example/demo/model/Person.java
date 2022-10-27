package com.example.demo.model;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.Past;

import javax.persistence.*;

import org.springframework.format.annotation.DateTimeFormat;

import com.fasterxml.jackson.annotation.JsonFormat;

@Entity
@Table(name = "person")
public class Person {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private long id;
  
  @Column(name = "name")
  @NotEmpty(message = "Name can't be empty")
  private String name;

  @Column(name = "gender")
  @NotEmpty(message = "Gender can't be empty")
  private String gender;

  @Column(name = "role")
  @NotEmpty(message = "Role can't be empty")
  private String role;

  @Column(name = "dateofjoining")
  @DateTimeFormat(pattern = "dd/MM/yyyy")
  @JsonFormat(shape = JsonFormat.Shape.STRING,pattern="dd/MM/yyyy")
  @Past(message = "Enter valid date.")
  private LocalDate dateofjoining;
  
  @Column(name = "dateofbirth")
  @DateTimeFormat(pattern = "dd/MM/yyyy")
  @JsonFormat(shape = JsonFormat.Shape.STRING,pattern="dd/MM/yyyy")
  @Past(message = "Enter valid date.")
  private LocalDate dateofbirth;

  @ManyToMany(fetch = FetchType.LAZY,
      cascade = {
          CascadeType.PERSIST,
          CascadeType.MERGE
      })
  @JoinTable(name = "person_school",
        joinColumns = { @JoinColumn(name = "person_id") },
        inverseJoinColumns = { @JoinColumn(name = "school_id") })
  private Set<School> schools = new HashSet<>();
  
  public Person() {

  }

  public Person(String name, String gender, String role) {
    this.name = name;
    this.gender = gender;
    this.role = role;
  }

  public long getId() {
    return id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getGender() {
    return gender;
  }

  public void setGender(String gender) {
    this.gender = gender;
  }

  public String getRole() {
    return role;
  }

  public void setRole(String role) {
    this.role = role;
  }

  public LocalDate getDateofjoining() {
    return dateofjoining;
  }

  public void setDateofjoining(LocalDate dateofjoining) {
    this.dateofjoining = dateofjoining;
  }

  public LocalDate getDateofbirth() {
    return dateofbirth;
  }

  public void setDateofbirth(LocalDate dateofbirth) {
    this.dateofbirth = dateofbirth;
  }

  public Set<School> getSchools() {
    return schools;
  }

  public void setSchools(Set<School> schools) {
    this.schools = schools;
  }
  
  public void addSchool(School school) {
    this.schools.add(school);
    school.getPersons().add(this);
  }
  
  public void removeSchool(long schoolId) {
    School school = this.schools.stream().filter(s -> s.getId() == schoolId).findFirst().orElse(null);
    if (school != null) {
      this.schools.remove(school);
      school.getPersons().remove(this);
    }
  }

  @Override
  public String toString() {
    return "Person [id=" + id + ", name =" + name + ", gender=" + gender + ", role=" + role + "]";
  }

}