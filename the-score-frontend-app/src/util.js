import axios from "axios";
import { BASE_URL } from "./components/App";

export function fetchCsvData(params) {
  const query = new URLSearchParams({
    filter: params.search,
    order_by: params.sort,
    order: params.order,
  });

  const url = `${BASE_URL}/csv?${query}`;

  axios({ url: url, method: "GET", responseType: "blob" }).then((response) =>
    downloadFile(response.data, "players.csv")
  );
}

function downloadFile(data, fileName) {
  const url = window.URL.createObjectURL(new Blob([data]));
  const link = document.createElement("a");
  link.href = url;
  link.setAttribute("download", fileName);
  document.body.appendChild(link);
  link.click();
}
