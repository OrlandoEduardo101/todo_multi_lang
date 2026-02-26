package com.todo.repository;

import com.todo.model.Todo;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TodoRepository extends JpaRepository<Todo, UUID> {

    List<Todo> findByUserIdAndDeletedAtIsNull(UUID userId);

    List<Todo> findByUserIdAndCompletedAndDeletedAtIsNull(UUID userId, Boolean completed);

    Optional<Todo> findByIdAndUserIdAndDeletedAtIsNull(UUID id, UUID userId);

    boolean existsByIdAndUserIdAndDeletedAtIsNull(UUID id, UUID userId);


    @Query("""
        SELECT t
        FROM Todo t
        WHERE t.user.id = :userId
          AND t.deletedAt IS NULL
          AND (:completed IS NULL OR t.completed = :completed)
          AND (:search IS NULL OR :search = '' OR LOWER(t.title) LIKE LOWER(CONCAT('%', :search, '%')))
    """)
    Page<Todo> findByUserWithFilters(
            @Param("userId") UUID userId,
            @Param("search") String search,
            @Param("completed") Boolean completed,
            Pageable pageable
    );

    @Query("""
        SELECT COUNT(t)
        FROM Todo t
        WHERE t.user.id = :userId
          AND t.deletedAt IS NULL
          AND (:completed IS NULL OR t.completed = :completed)
          AND (:search IS NULL OR :search = '' OR LOWER(t.title) LIKE LOWER(CONCAT('%', :search, '%')))
    """)
    long countByUserWithFilters(
            @Param("userId") UUID userId,
            @Param("search") String search,
            @Param("completed") Boolean completed
    );
}

