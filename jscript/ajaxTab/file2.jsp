<p><strong>Input box :</strong></p>
<form id="form1" name="form1" method="post" action="./index.jsp">
  <p>
    <input type="text" name="textfield2" value="<%=request.getParameter("textfield2")%>">
</p>
  <p>
    <input type="submit" name="Submit" value="Submit" />
</p>
</form>
<%
System.out.println(request.getParameter("textfield2"));
%>