package com.example.demo.controller;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.model.Person;
import com.example.demo.repository.PersonRepository;

@RestController
@RequestMapping("/api")
public class PersonController {

  @Autowired
  PersonRepository personRepository;

  @GetMapping("/persons")
  public ResponseEntity<List<Person>> getAllPersons(@RequestParam(required = false) String name) {
    List<Person> persons = new ArrayList<Person>();
    if (name == null)
      personRepository.findAll().forEach(persons::add);
    else
      personRepository.findByNameContaining(name).forEach(persons::add);

    if (persons.isEmpty()) {
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
    return new ResponseEntity<>(persons, HttpStatus.OK);
  }

  @GetMapping("/persons/{id}")
  public ResponseEntity<Person> getPersonById(@PathVariable("id") long id) {
    Person person = personRepository.findById(id)
        .orElseThrow(() -> new ResourceNotFoundException("Not found Person with id = " + id));
    return new ResponseEntity<>(person, HttpStatus.OK);
  }

  @PostMapping("/persons")
  public ResponseEntity<Person> createPerson(@RequestBody Person person) {
    //Person _person = personRepository.save(person);
    return new ResponseEntity<>(personRepository.save(person), HttpStatus.CREATED);
  }

  @PutMapping("/persons/{id}")
  public ResponseEntity<Person> updatePerson(@PathVariable("id") long id, @RequestBody Person person) {
    Person _person = personRepository.findById(id)
        .orElseThrow(() -> new ResourceNotFoundException("Not found Person with id = " + id));
    _person.setName(person.getName());
    _person.setGender(person.getGender());
    _person.setRole(person.getRole());
    _person.setDateofbirth(person.getDateofbirth());
    _person.setDateofjoining(person.getDateofjoining());
    return new ResponseEntity<>(personRepository.save(_person), HttpStatus.OK);
  }

  @DeleteMapping("/persons/{id}")
  public ResponseEntity<HttpStatus> deletePerson(@PathVariable("id") long id) {
    personRepository.deleteById(id);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @DeleteMapping("/persons")
  public ResponseEntity<HttpStatus> deleteAllPersons() {
    personRepository.deleteAll();
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping("/persons/admins")
  public ResponseEntity<List<Person>> findByAdminRole() {
    List<Person> persons = personRepository.findByRole("admin");
    if (persons.isEmpty()) {
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
    return new ResponseEntity<>(persons, HttpStatus.OK);
  }
}
