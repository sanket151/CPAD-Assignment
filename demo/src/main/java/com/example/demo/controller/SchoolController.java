package com.example.demo.controller;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.model.School;
import com.example.demo.model.Person;
import com.example.demo.repository.SchoolRepository;
import com.example.demo.repository.PersonRepository;


@RestController
@RequestMapping("/api")
public class SchoolController {

  @Autowired
  private PersonRepository personRepository;

  @Autowired
  private SchoolRepository schoolRepository;

  @GetMapping("/schools")
  public ResponseEntity<List<School>> getAllSchools() {
    List<School> schools = new ArrayList<School>();

    schoolRepository.findAll().forEach(schools::add);

    if (schools.isEmpty()) {
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    return new ResponseEntity<>(schools, HttpStatus.OK);
  }
  
  @GetMapping("/persons/{personId}/schools")
  public ResponseEntity<List<School>> getAllSchoolsByPersonId(@PathVariable(value = "personId") Long personId) {
    if (!personRepository.existsById(personId)) {
      throw new ResourceNotFoundException("Not found Person with id = " + personId);
    }

    List<School> schools = schoolRepository.findSchoolsByPersonsId(personId);
    return new ResponseEntity<>(schools, HttpStatus.OK);
  }

  @GetMapping("/schools/{id}")
  public ResponseEntity<School> getSchoolsById(@PathVariable(value = "id") Long id) {
    School school = schoolRepository.findById(id)
        .orElseThrow(() -> new ResourceNotFoundException("Not found School with id = " + id));

    return new ResponseEntity<>(school, HttpStatus.OK);
  }
  
  @GetMapping("/schools/{schoolId}/persons")
  public ResponseEntity<List<Person>> getAllPersonsBySchoolId(@PathVariable(value = "schoolId") Long schoolId) {
    if (!schoolRepository.existsById(schoolId)) {
      throw new ResourceNotFoundException("Not found School with id = " + schoolId);
    }

    List<Person> persons = personRepository.findPersonsBySchoolsId(schoolId);
    return new ResponseEntity<>(persons, HttpStatus.OK);
  }

  @PostMapping("/persons/{personId}/schools")
  public ResponseEntity<School> addSchools(@PathVariable(value = "personId") Long personId, @RequestBody School schoolRequest) {
    School school = personRepository.findById(personId).map(person -> {
      long schoolId = schoolRequest.getId();
      
      // school is existed
      if (schoolId != 0L) {
        School _school = schoolRepository.findById(schoolId)
            .orElseThrow(() -> new ResourceNotFoundException("Not found school with id = " + schoolId));
        person.addSchool(_school);
        personRepository.save(person);
        return _school;
      }
      
      // add and create new school
      person.addSchool(schoolRequest);
      return schoolRepository.save(schoolRequest);
    }).orElseThrow(() -> new ResourceNotFoundException("Not found person with id = " + personId));

    return new ResponseEntity<>(school, HttpStatus.CREATED);
  }

  @PutMapping("/schools/{id}")
  public ResponseEntity<School> updateSchools(@PathVariable("id") long id, @RequestBody School schoolRequest) {
    School school = schoolRepository.findById(id)
        .orElseThrow(() -> new ResourceNotFoundException("SchoolId " + id + "not found"));

    school.setName(schoolRequest.getName());

    return new ResponseEntity<>(schoolRepository.save(school), HttpStatus.OK);
  }
 
  @DeleteMapping("/persons/{personId}/schools/{schoolId}")
  public ResponseEntity<HttpStatus> deleteSchoolsFromPerson(@PathVariable(value = "personId") Long personId, @PathVariable(value = "schoolId") Long schoolId) {
    Person person = personRepository.findById(personId)
        .orElseThrow(() -> new ResourceNotFoundException("Not found Person with id = " + personId));
    
    person.removeSchool(schoolId);
    personRepository.save(person);
    
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }
  
  @DeleteMapping("/schools/{id}")
  public ResponseEntity<HttpStatus> deleteSchool(@PathVariable("id") long id) {
    schoolRepository.deleteById(id);

    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }
}