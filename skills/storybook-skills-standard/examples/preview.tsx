import type { Preview } from '@storybook/react-vite';
import { initialize, mswLoader } from 'msw-storybook-addon';
import { AppProviders } from '../src/app/AppProviders';

initialize();

const preview: Preview = {
  tags: ['autodocs'],
  loaders: [mswLoader],
  parameters: {
    layout: 'centered',
    controls: { expanded: true },
    a11y: { test: 'error' },
  },
  globalTypes: {
    theme: {
      toolbar: {
        title: 'Theme',
        items: ['light', 'dark'],
      },
    },
    locale: {
      toolbar: {
        title: 'Locale',
        items: ['zh-CN', 'en-US'],
      },
    },
  },
  decorators: [
    (Story, context) => (
      <AppProviders theme={context.globals.theme} locale={context.globals.locale}>
        <Story />
      </AppProviders>
    ),
  ],
};

export default preview;
