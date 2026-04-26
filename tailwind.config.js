/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./lib/**/*.dart", "./web/*.html"],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#00D47E',
          '50': '#E6FFF5',
          '100': '#CCFFEB',
          '200': '#99FFD6',
          '300': '#66FFC2',
          '400': '#33FFAD',
          '500': '#00D47E',
          '600': '#00B36B',
          '700': '#008C54',
          '800': '#00663D',
          '900': '#004026',
          '950': '#002617',
        },
        accent: '#00D47E',
        dark: {
          'bg': '#09090B',
          'card': '#18181B',
          'border': '#27272A',
          'muted': '#71717A',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      keyframes: {
        'fade-in': {
          'from': { opacity: '0' },
          'to': { opacity: '1' },
        },
        'slide-in-from-right': {
          'from': { transform: 'translateX(100%)' },
          'to': { transform: 'translateX(0)' },
        },
        'slide-up': {
          'from': { transform: 'translateY(10px)', opacity: '0' },
          'to': { transform: 'translateY(0)', opacity: '1' },
        },
      },
      animation: {
        'in': 'fade-in 0.3s ease-out',
        'slide-in-from-right': 'slide-in-from-right 0.3s ease-out',
        'slide-up': 'slide-up 0.4s ease-out',
      },
      boxShadow: {
        'glow-primary': '0 0 20px rgba(0, 212, 126, 0.15)',
      },
    },
  },
  plugins: [],
}
