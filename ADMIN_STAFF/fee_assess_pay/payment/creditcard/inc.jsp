<script language="javascript">
function LinkTo(strPageURL) {
/**
	if(document.form_.phy_id_no.value.length == 0) {
		alert("Please enter physician ID Number");
		document.form_.phy_id_no.focus();
		return;
	}
	location =strPageURL+"?phy_id_no="+document.form_.phy_id_no.value;
**/
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
        <td width="50" bgcolor="#a9b9d1" align="center" class="tabFont">Setting</td>
        <td background="../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="50" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./setting.jsp');">Setting</a></td>
        <td background="../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        
<%if(iPgIndex == 2){%>
        <td background="../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Manage Card Type</td>
        <td background="../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./manage_card.jsp');">Manage Card Type</a></td>
        <td background="../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        
<%if(iPgIndex == 3){%>
        <td background="../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="100" bgcolor="#a9b9d1" align="center" class="tabFont">Manage Bank</td>
        <td background="../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="100" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./manage_bank.jsp');">Manage Bank</a></td>
        <td background="../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
      </tr>
	</table>
