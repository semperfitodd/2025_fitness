import React, { useState, useEffect } from "react";
import { fetchFitnessData } from "../utils/api";
import ExerciseList from "../components/ExerciseList";
import ProgressBarGraph from "../components/ProgressBarGraph";

const Home = () => {
  const [data, setData] = useState([]);
  const [totalLifted, setTotalLifted] = useState(0);

  useEffect(() => {
    const loadData = async () => {
      const result = await fetchFitnessData();
      setData(result);

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

  // Calculate days into the year
  const currentDate = new Date();
  const startOfYear = new Date(currentDate.getFullYear(), 0, 1);
  const daysIntoYear = Math.ceil((currentDate - startOfYear) / (1000 * 60 * 60 * 24));

  return (
    <div>
      <ProgressBarGraph totalLifted={totalLifted} daysIntoYear={daysIntoYear} />
      <ExerciseList exercises={exercises} />
    </div>
  );
};

export default Home;
