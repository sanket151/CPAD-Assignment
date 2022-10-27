package com.example.demo.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.model.School;

public interface SchoolRepository extends JpaRepository<School, Long> {
  List<School> findSchoolsByPersonsId(Long personId);
}
