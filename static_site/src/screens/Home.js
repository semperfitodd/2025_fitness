import React, { useState, useEffect } from "react";
import { fetchFitnessData } from "../utils/api";
import ProgressBarGraph from "../components/ProgressBarGraph";
import PieChart from "../components/PieChart";

const Home = () => {
  const [totalLifted, setTotalLifted] = useState(0);
  const [exerciseData, setExerciseData] = useState({});

  useEffect(() => {
    const loadData = async () => {
      const result = await fetchFitnessData();

      // Find "total_lifted" for the progress bar
      const totalLiftedData = result.find(
        (exercise) => exercise.exercise_name === "total_lifted"
      );
      setTotalLifted(totalLiftedData?.total_volume || 0);

      // Prepare data for PieChart
      const exercises = {};
      result.forEach((entry) => {
        if (entry.exercise_name !== "total_lifted" && entry.total_volume) {
          exercises[entry.exercise_name] = entry.total_volume;
        }
      });
      setExerciseData(exercises);
    };

    loadData();
  }, []);

  // Calculate days into the year
  const currentDate = new Date();
  const startOfYear = new Date(currentDate.getFullYear(), 0, 1);
  const daysIntoYear = Math.ceil((currentDate - startOfYear) / (1000 * 60 * 60 * 24));

  return (
    <div>
      <h2 style={{ textAlign: "center", marginBottom: "20px" }}>Progress Overview</h2>
      <div style={{ display: "flex", justifyContent: "space-around", alignItems: "flex-start", flexWrap: "wrap", gap: "20px" }}>
        <div style={{ flex: "1 1 45%", minWidth: "300px" }}>
          <ProgressBarGraph totalLifted={totalLifted} daysIntoYear={daysIntoYear} />
        </div>
        <div style={{ flex: "1 1 45%", minWidth: "300px" }}>
          <PieChart exercises={exerciseData} />
        </div>
      </div>
    </div>
  );
};

export default Home;
