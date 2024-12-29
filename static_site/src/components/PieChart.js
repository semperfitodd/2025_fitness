import React from 'react';
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
} from 'chart.js';
import { Pie } from 'react-chartjs-2';

ChartJS.register(ArcElement, Tooltip, Legend);

const PieChart = ({ exercises }) => {
  const labels = Object.keys(exercises);
  const dataValues = Object.values(exercises);

  const colorPalette = [
    '#FF5733', '#33FF57', '#3357FF', '#FF33A8', '#33FFF2', '#FF8C33', '#A833FF', '#33FF8C', '#FF3333',
    '#33FFDD', '#FFC300', '#DAF7A6', '#C70039', '#900C3F', '#581845', '#FFC0CB', '#FFD700', '#40E0D0',
  ];

  const backgroundColors = labels.map((_, index) =>
    colorPalette[index % colorPalette.length]
  );

  const borderColors = labels.map((_, index) =>
    backgroundColors[index]
  );

  const data = {
    labels,
    datasets: [
      {
        data: dataValues,
        backgroundColor: backgroundColors,
        borderColor: borderColors,
        borderWidth: 1,
      },
    ],
  };

  const options = {
    responsive: true,
    plugins: {
      legend: {
        position: 'right',
      },
      tooltip: {
        callbacks: {
          label: function (context) {
            const label = context.label || '';
            const value = context.raw || 0;
            const total = dataValues.reduce((a, b) => a + b, 0);
            const percentage = ((value / total) * 100).toFixed(2);
            return `${label}: ${value.toLocaleString()} lbs (${percentage}%)`;
          },
        },
      },
    },
  };

  return (
    <div style={{ width: '80%', margin: '0 auto' }}>
      <Pie data={data} options={options} />
    </div>
  );
};

export default PieChart;
