<%@ Page Language="C#" AutoEventWireup="true" CodeFile="api.aspx.cs" Inherits="Docs_Api" %>
<%@ Import Namespace="System.Net.Http" %>
<%@ Import Namespace="System.Text.Json" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Dynamic" %>

<!— Obfuscated API documentation page —>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>QL7 Bank API</title>
    <style>
        body { font-family: Consolas, monospace; background: #1e1e1e; color: #dcdcdc; }
        .section { margin: 20px; padding: 10px; border: 1px solid #444; }
        .hdr { font-weight: bold; color: #9cdcfe; }
    </style>
</head>
<body>
    <form id="f" runat="server">
    <asp:Literal ID="litContent" runat="server" />
    </form>
</body>
</html>
