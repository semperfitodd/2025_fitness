// Error tracking utilities for production
export const logError = (error, context = {}) => {
    // In production, this would send to Sentry, LogRocket, or similar
    console.error('Application Error:', {
        message: error.message,
        stack: error.stack,
        context,
        timestamp: new Date().toISOString(),
        userAgent: navigator.userAgent,
        url: window.location.href
    });
    
    // You can add Sentry here:
    // Sentry.captureException(error, { extra: context });
};

export const logUserAction = (action, data = {}) => {
    // Track user actions for analytics
    console.log('User Action:', {
        action,
        data,
        timestamp: new Date().toISOString(),
        url: window.location.href
    });
    
    // You can add Google Analytics here:
    // gtag('event', action, data);
};

export const logPerformance = (metric, value) => {
    // Track performance metrics
    console.log('Performance Metric:', {
        metric,
        value,
        timestamp: new Date().toISOString()
    });
};
