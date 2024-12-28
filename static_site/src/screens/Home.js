import React, { useState, useEffect } from "react";
import { fetchFitnessData } from "../utils/api";
import Header from "../components/Header";
import ExerciseList from "../components/ExerciseList";

const Home = () => {
  const [data, setData] = useState([]);
  const [totalLifted, setTotalLifted] = useState(0);

  useEffect(() => {
    const loadData = async () => {
      const result = await fetchFitnessData();
      setData(result);

      // Find "total_lifted"
      const totalLiftedData = result.find(
        (exercise) => exercise.exercise_name === "total_lifted"
      );
      setTotalLifted(totalLiftedData?.total_volume || 0);
    };

    loadData();
  }, []);

  const exercises = data.filter(
    (exercise) => exercise.exercise_name !== "total_lifted"
  );

  return (
    <div>
      <Header date={new Date().toLocaleDateString()} />
      <h3>Total Lifted: {totalLifted.toLocaleString()} pounds</h3>
      <ExerciseList exercises={exercises} />
    </div>
  );
};

export default Home;
