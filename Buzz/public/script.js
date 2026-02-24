document.addEventListener('DOMContentLoaded', () => {
    // Mobile Navigation Toggle
    const navToggle = document.getElementById('nav-toggle');
    const navList = document.querySelector('.nav-list');
    const navLinks = document.querySelectorAll('.nav-link');

    if (navToggle) {
        navToggle.addEventListener('click', () => {
            navList.classList.toggle('active');

            // Toggle icon
            const icon = navToggle.querySelector('i');
            if (navList.classList.contains('active')) {
                icon.classList.remove('fa-bars');
                icon.classList.add('fa-times');
            } else {
                icon.classList.remove('fa-times');
                icon.classList.add('fa-bars');
            }
        });
    }

    // Close mobile menu when a link is clicked
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            if (navList.classList.contains('active')) {
                navList.classList.remove('active');
                const icon = navToggle.querySelector('i');
                icon.classList.remove('fa-times');
                icon.classList.add('fa-bars');
            }
        });
    });

    // Header Scroll Effect
    const header = document.getElementById('header');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            header.style.boxShadow = '0 5px 20px rgba(0,0,0,0.5)';
            header.style.backgroundColor = 'rgba(0, 0, 0, 0.95)';
        } else {
            header.style.boxShadow = 'none';
            header.style.backgroundColor = 'rgba(0, 0, 0, 0.85)';
        }
    });

    // FAQ Accordion
    const faqItems = document.querySelectorAll('.faq-item');

    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        question.addEventListener('click', () => {
            // Close other items
            faqItems.forEach(otherItem => {
                if (otherItem !== item) {
                    otherItem.classList.remove('active');
                }
            });
            // Toggle current item
            item.classList.toggle('active');
        });
    });

    // Smooth Scroll for Anchor Links (Backup for older browsers)
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;

            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                // Account for fixed header height
                const headerHeight = 80;
                const elementPosition = targetElement.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerHeight;

                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
    // Scroll Spy & Active Link Logic
    const sections = document.querySelectorAll('section[id]'); // Only select sections with IDs
    const navItems = document.querySelectorAll('.nav-link');
    const path = window.location.pathname;
    const page = path.split("/").pop(); // Get current filename

    function updateActiveLink() {
        // 1. Handle Sub-pages (Static Highlighting)
        if (page === 'about.html' || page === 'privacy.html') {
            navItems.forEach(link => {
                link.classList.remove('active');
                if (link.getAttribute('href') === page) {
                    link.classList.add('active');
                }
            });
            return; // Stop here, don't run scroll spy on sub-pages
        }

        // 2. Handle Home Page (Scroll Spy)
        let currentSection = '';

        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            // Offset for header height
            if (window.scrollY >= (sectionTop - 150)) {
                currentSection = section.getAttribute('id');
            }
        });

        // Default to home if at top
        if (window.scrollY < 100) {
            currentSection = 'home';
        }

        navItems.forEach(link => {
            link.classList.remove('active');
            // Check if link points to the current section (e.g. #features)
            // We use endsWith or check if href includes the hash
            const href = link.getAttribute('href');
            if (currentSection && href.includes('#' + currentSection)) {
                link.classList.add('active');
            }
        });
    }

    // Run on scroll
    window.addEventListener('scroll', updateActiveLink);
    // Run on load
    updateActiveLink();
});
