import React from 'react';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';
import { Bar } from 'react-chartjs-2';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

const ProgressBarGraph = ({ totalLifted, daysIntoYear }) => {
  const totalLiftedPercentage = (totalLifted / 15000000) * 100;
  const daysIntoYearPercentage = (daysIntoYear / 365) * 100;

  const data = {
    labels: ['Total Lifted', 'Days Into Year'],
    datasets: [
      {
        label: 'Progress (%)',
        data: [totalLiftedPercentage, daysIntoYearPercentage],
        backgroundColor: ['#FFFF00', '#FF0000'],
        borderColor: ['#B2B200', '#B20000'],
        borderWidth: 1,
      },
    ],
  };

  const options = {
    responsive: true,
    indexAxis: 'y',
    maintainAspectRatio: false,
    scales: {
      x: {
        beginAtZero: true,
        max: 100,
        ticks: {
          callback: (value) => `${value}%`,
        },
        title: {
          display: true,
          text: 'Percentage (%)',
        },
      },
      y: {
        title: {
          display: true,
          text: 'Metrics',
        },
      },
    },
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        callbacks: {
          label: function (context) {
            if (context.label === 'Total Lifted') {
              return `Total Lifted: ${totalLifted.toLocaleString()} lbs (${totalLiftedPercentage.toFixed(
                2
              )}%)`;
            } else if (context.label === 'Days Into Year') {
              return `Days Into Year: ${daysIntoYear} days (${daysIntoYearPercentage.toFixed(2)}%)`;
            }
            return '';
          },
        },
      },
    },
  };

  return (
    <div style={{ width: '80%', margin: '0 auto' }}>
      <Bar data={data} options={options} height={200} />
    </div>
  );
};

export default ProgressBarGraph;
