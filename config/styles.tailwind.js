const flatmateColors = {
  'flatmate-900': '#091736',
  'flatmate-800': '#264079',
  'flatmate-700': '#335FBF',
  'flatmate-600': '#4C7ADD',
  'flatmate-500': '#4F82F2',
  'flatmate-400': '#6694F9',
  'flatmate-300': '#90B3FF',
  'flatmate-200': '#CCDCFF',
  'flatmate-100': '#F5F8FF',
};

module.exports = {
  theme: {
    fontFamily: {
      base: ['Work Sans', 'sans serif'],
    },
    extend: {
      colors: flatmateColors,
      boxShadow: {
        'flatmate-100-300': `0 0 0 2px ${flatmateColors['flatmate-100']}, 0 0 0 4px ${flatmateColors['flatmate-300']}`,
        'flatmate-100-500': `0 0 0 2px ${flatmateColors['flatmate-100']}, 0 0 0 4px ${flatmateColors['flatmate-500']}`,
      },
    }
  },
  variants: [],
  purge: false,
  corePlugins: {},
  plugins: [],
};
