package com.example.demo.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.model.Person;

public interface PersonRepository extends JpaRepository<Person, Long> {
  List<Person> findByRole(String role);

  List<Person> findByNameContaining(String name);
  
  List<Person> findPersonsBySchoolsId(Long schoolId);
}