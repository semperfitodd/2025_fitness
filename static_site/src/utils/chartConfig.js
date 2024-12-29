export const colorPalette = [
    '#FF5733', '#33FF57', '#3357FF', '#FF33A8', '#33FFF2', '#FF8C33', '#A833FF', '#33FF8C', '#FF3333',
    '#33FFDD', '#FFC300', '#DAF7A6', '#C70039', '#900C3F', '#581845', '#FFC0CB', '#FFD700', '#40E0D0'
];

export const chartOptions = {
    plugins: {
        legend: {position: 'right'},
        tooltip: {
            callbacks: {
                label: (context) => {
                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                    const percentage = ((context.raw / total) * 100).toFixed(2);
                    return `${context.label}: ${context.raw.toLocaleString()} lbs (${percentage}%)`;
                },
            },
        },
    },
    responsive: true,
};
