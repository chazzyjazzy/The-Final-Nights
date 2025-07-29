import { classes } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Table } from 'tgui-core/components';
import { Window } from '../layouts';

export const SpellbookVendor = (props) => {
  const { act, data } = useBackend();
  let inventory = [...data.product_records];

  // Determine greeting based on knowledge
  const getGreeting = () => {
    if (data.user && data.user.has_thaumaturgy) {
      return "Greetings, student of the blood...";
    } else if (data.user && data.user.has_necromancy) {
      return "Greetings, student of the shroud...";
    } else {
      return "Greetings, seeker...";
    }
  };

  return (
    <Window width={465} height={600} resizable theme="blood_cult">
      <Window.Content scrollable>
        <Section
          title="Practitioner"
          style={{
            'background-color': '#1a0000',
            'border-color': '#4d0000',
            'color': '#cc3333'
          }}
        >
          {data.user && (
            <Box style={{ 'color': '#cc3333' }}>
              {getGreeting()}
              <br />
              You have <b style={{ 'color': '#ff4444' }}>
                {data.user.points} research points
              </b>.
            </Box>
          )}
        </Section>
        <Section
          title="The Archives"
          style={{
            'background-color': '#1a0000',
            'border-color': '#4d0000',
            'color': '#cc3333'
          }}
        >
          <Table style={{ 'background-color': '#0d0000' }}>
            {inventory.map((product) => {
              return (
                <Table.Row
                  key={product.name}
                  style={{
                    'background-color': '#1a0000',
                    'border-color': '#4d0000'
                  }}
                >
                  <Table.Cell style={{ 'color': '#cc3333' }}>
                    <span
                      className={classes(['vending32x32', product.path])}
                      style={{
                        'vertical-align': 'middle',
                        'filter': 'hue-rotate(0deg) saturate(1.2) brightness(0.9)'
                      }}
                    />{' '}
                    <b style={{ 'color': '#ff4444' }}>{product.name}</b>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      style={{
                        'min-width': '105px',
                        'text-align': 'center',
                        'background-color': product.price > (data.user?.points || 0) ? '#4d1a1a' : '#660000',
                        'border-color': '#990000',
                        'color': product.price > (data.user?.points || 0) ? '#996666' : '#ffcccc'
                      }}
                      disabled={!data.user || product.price > data.user.points}
                      content={product.price + ' research points'}
                      onClick={() =>
                        act('purchase', {
                          ref: product.ref,
                        })
                      }
                    />
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
