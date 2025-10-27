/**
 * Test Custom Plugin JavaScript
 */

(function() {
    'use strict';
    
    console.log('Test Custom Plugin is loaded! 🎉');
    
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
    
    function init() {
        // Add a click handler to the message
        const message = document.getElementById('test-custom-plugin-message');
        if (message) {
            message.addEventListener('click', function() {
                this.style.transform = 'scale(0.95)';
                setTimeout(() => {
                    this.style.transform = 'scale(1)';
                }, 150);
            });
            
            console.log('Test plugin initialized successfully!');
        }
    }
})();

