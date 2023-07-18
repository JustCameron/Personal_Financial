"""empty message

Revision ID: e474d27275ba
Revises: 3a3e6bb0e157
Create Date: 2023-07-17 01:36:14.195454

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'e474d27275ba'
down_revision = '3a3e6bb0e157'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('expense_categories', schema=None) as batch_op:
        batch_op.add_column(sa.Column('ttl_cost', sa.Numeric(precision=10, scale=2), nullable=True))
        batch_op.drop_column('ttlCost')

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('expense_categories', schema=None) as batch_op:
        batch_op.add_column(sa.Column('ttlCost', sa.NUMERIC(precision=10, scale=2), autoincrement=False, nullable=True))
        batch_op.drop_column('ttl_cost')

    # ### end Alembic commands ###
