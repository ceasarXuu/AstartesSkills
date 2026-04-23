import type { Meta, StoryObj } from '@storybook/react-vite';
import { expect, fn } from 'storybook/test';
import { LoginForm } from './LoginForm';

const meta = {
  title: 'Patterns/Auth/LoginForm',
  component: LoginForm,
  args: {
    onSubmit: fn(),
  },
  parameters: {
    a11y: { test: 'error' },
  },
} satisfies Meta<typeof LoginForm>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Empty: Story = {};

export const FilledAndSubmitted: Story = {
  play: async ({ canvas, userEvent, args }) => {
    await userEvent.type(canvas.getByLabelText('邮箱'), 'demo@example.com');
    await userEvent.type(canvas.getByLabelText('密码'), 'correct-horse-battery-staple');
    await userEvent.click(canvas.getByRole('button', { name: '登录' }));
    await expect(args.onSubmit).toHaveBeenCalled();
  },
};
