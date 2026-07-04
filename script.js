'use strict';

document.addEventListener('DOMContentLoaded', () => {
    // DOM Elements
    const menuToggle = document.querySelector('.menu-toggle');
    const navLinks = document.querySelector('.nav-links');
    const contactForm = document.getElementById('contactForm');

    // Mobile Navigation Toggle
    if (menuToggle && navLinks) {
        menuToggle.addEventListener('click', () => {
            const isActive = navLinks.classList.toggle('active');
            menuToggle.setAttribute('aria-expanded', isActive);
            
            // Hamburger animation
            const spans = menuToggle.querySelectorAll('span');
            if (isActive) {
                spans[0].style.transform = 'rotate(45deg) translate(6px, 6px)';
                spans[1].style.opacity = '0';
                spans[2].style.transform = 'rotate(-45deg) translate(5px, -5px)';
            } else {
                spans[0].style.transform = 'none';
                spans[1].style.opacity = '1';
                spans[2].style.transform = 'none';
            }
        });

        // Close menu on link click
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                if (navLinks.classList.contains('active')) {
                    menuToggle.click();
                }
            });
        });
    }

    // Contact Form Handling (Secure Mock Submission)
    if (contactForm) {
        contactForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const submitBtn = contactForm.querySelector('button[type="submit"]');
            if (!submitBtn) return;
            
            const originalText = submitBtn.textContent;
            
            try {
                // UI Loading state
                submitBtn.textContent = 'Mengirim...';
                submitBtn.disabled = true;
                
                // Simulate network request
                await new Promise(resolve => setTimeout(resolve, 1200));
                
                // Success state
                submitBtn.textContent = 'Pesan Terkirim!';
                submitBtn.style.background = '#00C853'; // Material Green
                contactForm.reset();
                
            } catch (error) {
                // Error state
                console.error('Form submission failed:', error);
                submitBtn.textContent = 'Gagal Mengirim';
                submitBtn.style.background = '#D50000'; // Material Red
            } finally {
                // Revert state
                setTimeout(() => {
                    submitBtn.textContent = originalText;
                    submitBtn.style.background = '';
                    submitBtn.disabled = false;
                }, 3000);
            }
        });
    }
});
