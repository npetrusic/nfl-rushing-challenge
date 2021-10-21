import {
  Table as ReactTable,
  Header,
  HeaderRow,
  HeaderCell,
  Body,
} from "@table-library/react-table-library/table";
import { Row, Cell } from "@table-library/react-table-library/table";

export function Table({ data, pagination, onSortClick }) {
  return (
    <ReactTable data={data} pagination={pagination}>
      {(tableList) => (
        <>
          <Header>
            <HeaderRow>
              {table_fields.map((field) => (
                <HeaderCell className="header-cell" key={field.title}>
                  {field.sortKey ? (
                    <button onClick={() => onSortClick(field.sortKey)}>
                      {field.title}
                    </button>
                  ) : (
                    field.title
                  )}
                </HeaderCell>
              ))}
            </HeaderRow>
          </Header>

          <Body>
            {tableList.map((item) => (
              <TableRow key={item.Player} item={item} />
            ))}
          </Body>
        </>
      )}
    </ReactTable>
  );
}

function TableRow({ item }) {
  return (
    <Row className="row">
      {table_fields.map((field) => (
        <Cell className="cell" key={field.title}>{item[field.title]}</Cell>
      ))}
    </Row>
  );
}

const table_fields = [
  {
    title: "Player",
    sortKey: "player",
  },
  {
    title: "Team",
  },
  {
    title: "Pos",
  },
  {
    title: "Att",
  },
  {
    title: "Att/G",
  },
  {
    title: "Yds",
    sortKey: "yards",
  },
  {
    title: "Avg",
  },
  {
    title: "Yds/G",
  },
  {
    title: "TD",
    sortKey: "touchdowns",
  },
  {
    title: "Lng",
    sortKey: "longest_rush",
  },
  {
    title: "1st",
  },
  {
    title: "1st%",
  },
  {
    title: "20+",
  },
  {
    title: "40+",
  },
  {
    title: "FUM",
  },
];
