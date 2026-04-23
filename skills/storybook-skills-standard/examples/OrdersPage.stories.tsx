import type { Meta, StoryObj } from '@storybook/react-vite';
import { delay, http, HttpResponse } from 'msw';

import { OrdersPage } from './OrdersPage';
import * as HeaderStories from '../Header/Header.stories';
import * as OrderTableStories from '../OrderTable/OrderTable.stories';

const meta = {
  title: 'Screens/Orders/OrdersPage',
  component: OrdersPage,
  tags: ['autodocs', 'stable', 'page'],
  parameters: {
    layout: 'fullscreen',
  },
  args: {
    header: HeaderStories.LoggedIn.args,
    rows: OrderTableStories.WithResults.args?.rows ?? [],
  },
} satisfies Meta<typeof OrdersPage>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Loaded: Story = {};

export const Empty: Story = {
  args: {
    rows: [],
  },
};

export const Error: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/orders', async () => {
          await delay(500);
          return new HttpResponse(null, { status: 500 });
        }),
      ],
    },
  },
};
