import { useState, useEffect, useCallback } from "react";
import { usePagination } from "@table-library/react-table-library/pagination";
import { useCustom } from "@table-library/react-table-library/table";
import axios from "axios";

import { Table } from "./Table";
import { useIsMounted, useDebounce } from "../customHooks";

import "../App.css";
import { fetchCsvData } from "../util";

export const BASE_URL = "http://localhost:4000/players";

const INITIAL_PARAMS = {
  search: "",
  next_page: "",
  sort: "player",
  order: "asc",
};

export const App = () => {
  const isMounted = useIsMounted();
  const [data, setData] = useState({
    nodes: [],
    next_page: null,
    sort: INITIAL_PARAMS.sort,
    order: INITIAL_PARAMS.order,
    search: INITIAL_PARAMS.search,
  });

  const [search, setSearch] = useState(INITIAL_PARAMS.search);
  const [sort, setSort] = useState(INITIAL_PARAMS.sort);
  const [order, setOrder] = useState(INITIAL_PARAMS.order);

  const fetchData = useCallback(
    async (params) => {
      const query = new URLSearchParams({
        next_page: params.next_page,
        filter: params.search,
        order_by: params.sort,
        order: params.order,
      });

      const result = await axios.get(`${BASE_URL}?${query}`);
      if (!isMounted()) {
        return;
      }

      setData({
        nodes: result.data.players,
        next_page: result.data.next_page,
        sort: params.sort,
        order: params.order,
        search: params.search,
      });
    },
    [isMounted]
  );

  useEffect(() => {
    fetchData({
      search: INITIAL_PARAMS.search,
      next_page: INITIAL_PARAMS.next_page,
      sort: INITIAL_PARAMS.sort,
      order: INITIAL_PARAMS.order,
    });
  }, [fetchData]);

  const handleSearch = useCallback((event) => {
    setSearch(event.target.value);
  }, []);

  const handleSort = useCallback(
    (event) => {
      if (sort === event) {
        setOrder(order === "asc" ? "desc" : "asc");
      } else {
        setSort(event);
        setOrder(event === "player" ? "asc" : "desc");
      }
    },
    [sort, order]
  );

  const pagination = usePagination(
    data,
    {
      state: {
        next_page: INITIAL_PARAMS.next_page,
      },
      onChange: (_, state) =>
        fetchData({
          search,
          next_page: state.page,
          sort,
          order,
        }),
    },
    {
      isServer: true,
    }
  );

  useCustom("search", data, {
    state: { search },
    onChange: useDebounce((_, state) => {
      fetchData({
        search: state.search,
        next_page: pagination.state.next_page,
        sort,
        order,
      });
    }, 200),
  });

  useCustom("sort", data, {
    state: { sort, order },
    onChange: () =>
      fetchData({
        search,
        next_page: "",
        sort,
        order,
      }),
  });

  return (
    <>
      <SearchBox defaultValue={search} onQueryChange={handleSearch} />
      <Table
        className="table"
        data={data}
        onSortClick={handleSort}
        pagination={pagination}
      />
      <div className="button-container">
        <button
          className="control-button"
          disabled={data.next_page == null}
          onClick={() => pagination.fns.onSetPage(data.next_page)}
        >
          Next
        </button>
        <button className="control-button" onClick={() => fetchCsvData(data)}>
          Download CSV
        </button>
      </div>
    </>
  );
};

function SearchBox({ defaultValue, onQueryChange }) {
  return (
    <input
      id="search"
      type="text"
      defaultValue={defaultValue}
      placeholder="Search by player name..."
      onChange={onQueryChange}
    />
  );
}
