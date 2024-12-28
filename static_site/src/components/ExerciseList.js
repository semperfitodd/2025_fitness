import React from "react";

const ExerciseList = ({ exercises }) => {
  return (
    <div>
      <h3>Breakdown by Exercise</h3>
      <ul>
        {exercises.map((exercise, index) => (
          <li key={index}>
            {exercise.exercise_name}: {exercise.total_volume.toLocaleString()} pounds
          </li>
        ))}
      </ul>
    </div>
  );
};

export default ExerciseList;
