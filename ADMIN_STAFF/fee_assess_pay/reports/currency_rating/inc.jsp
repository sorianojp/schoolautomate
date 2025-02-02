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
        <td width="100" bgcolor="#a9b9d1" align="center" class="tabFont">Currency Type</td>
        <td background="../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="100" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./manage_currency.jsp');">Currency Type</a></td>
        <td background="../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        
<%if(iPgIndex == 2){%>
        <td background="../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Currency Rate</td>
        <td background="../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./conversion_history.jsp');">Currency Rate</a></td>
        <td background="../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        
      </tr>
	</table>
