"""empty message

Revision ID: 424383bc5891
Revises: de25414bbc1d
Create Date: 2023-07-22 18:47:10.311729

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '424383bc5891'
down_revision = 'de25414bbc1d'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('recommendation_report', schema=None) as batch_op:
        batch_op.alter_column('wants',
               existing_type=sa.INTEGER(),
               type_=sa.Numeric(precision=10, scale=2),
               nullable=True)
        batch_op.alter_column('needs',
               existing_type=sa.INTEGER(),
               type_=sa.Numeric(precision=10, scale=2),
               nullable=True)
        batch_op.alter_column('savings',
               existing_type=sa.INTEGER(),
               type_=sa.Numeric(precision=10, scale=2),
               nullable=True)
        batch_op.alter_column('rwants',
               existing_type=sa.INTEGER(),
               type_=sa.Numeric(precision=10, scale=2),
               nullable=True)
        batch_op.alter_column('rneeds',
               existing_type=sa.INTEGER(),
               type_=sa.Numeric(precision=10, scale=2),
               nullable=True)
        batch_op.alter_column('rsavings',
               existing_type=sa.INTEGER(),
               type_=sa.Numeric(precision=10, scale=2),
               nullable=True)

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('recommendation_report', schema=None) as batch_op:
        batch_op.alter_column('rsavings',
               existing_type=sa.Numeric(precision=10, scale=2),
               type_=sa.INTEGER(),
               nullable=False)
        batch_op.alter_column('rneeds',
               existing_type=sa.Numeric(precision=10, scale=2),
               type_=sa.INTEGER(),
               nullable=False)
        batch_op.alter_column('rwants',
               existing_type=sa.Numeric(precision=10, scale=2),
               type_=sa.INTEGER(),
               nullable=False)
        batch_op.alter_column('savings',
               existing_type=sa.Numeric(precision=10, scale=2),
               type_=sa.INTEGER(),
               nullable=False)
        batch_op.alter_column('needs',
               existing_type=sa.Numeric(precision=10, scale=2),
               type_=sa.INTEGER(),
               nullable=False)
        batch_op.alter_column('wants',
               existing_type=sa.Numeric(precision=10, scale=2),
               type_=sa.INTEGER(),
               nullable=False)

    # ### end Alembic commands ###
