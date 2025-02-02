<script language="javascript">
function LinkTo(strPageURL) {
	location =strPageURL;
}
</script>
<%
int iPgIndex = Integer.parseInt(request.getParameter("pgIndex"));
%>    
<table border="0" cellpadding="0" cellspacing="0">
      <tr>
<%if(iPgIndex == 1){%>
        <td background="../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Add/Drop Setup</td>
        <td background="../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./add_drop_main.jsp');">Add/Drop Setup</a></td>
        <td background="../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        
<%if(iPgIndex == 2){%>
        <td background="../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="50" bgcolor="#a9b9d1" align="center" class="tabFont">Search</td>
        <td background="../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="50" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./search.jsp');">Search</a></td>
        <td background="../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
<!--        
<%if(iPgIndex == 3){%>
        <td background="../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="140" bgcolor="#a9b9d1" align="center" class="tabFont">Invalidate Add/Drop</td>
        <td background="../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="140" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./invalidate.jsp');">Invalidate Add/Drop</a></td>
        <td background="../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
-->
      </tr>
	</table>
