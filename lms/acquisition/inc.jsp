<%

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

int iPgIndex      = Integer.parseInt(request.getParameter("pgIndex"));
%>    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
<%if(iPgIndex == 1){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="60" bgcolor="#a9b9d1" align="center" class="tabFont">Summary</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="60" bgcolor="#000000" align="center"><a href="./summary.jsp">Summary</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        <td width="2">&nbsp;</td>
<%if(iPgIndex == 2){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="50" bgcolor="#a9b9d1" align="center" class="tabFont">Budget  </td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="50" bgcolor="#000000" align="center"><a href="./budget_setup.jsp">Budget </a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
	<td width="2">&nbsp;</td>
<%if(iPgIndex == 3){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="55" bgcolor="#a9b9d1" align="center" class="tabFont"> Selection </td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="55" bgcolor="#000000" align="center"><a href="./selection.jsp">Selection</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        <td width="2">&nbsp;</td>
<%if(iPgIndex == 4){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="60" bgcolor="#a9b9d1" align="center" class="tabFont">Acquisition</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="60" bgcolor="#000000" align="center"><a href="./acquisition_main.jsp">Acquisition</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        <td width="2">&nbsp;</td>
<%if(iPgIndex == 5){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="100" bgcolor="#a9b9d1" align="center" class="tabFont">Actual Costing</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="100" bgcolor="#000000" align="center"><a href="./acquisition_final.jsp">Actual Costing</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>

<%if(strSchCode.startsWith("CIT")){%>

        <td width="2">&nbsp;</td>
<%if(iPgIndex == 6){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="100" bgcolor="#a9b9d1" align="center" class="tabFont">Entries Page</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="100" bgcolor="#000000" align="center"><a href="./other_entries.jsp">Entries Page</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>

	<td width="2">&nbsp;</td>
<%if(iPgIndex == 8){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="100" bgcolor="#a9b9d1" align="center" class="tabFont">Reports</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="100" bgcolor="#000000" align="center"><a href="./report_generation.jsp">Reports</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
<%}%>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td height="10" colspan="12" valign="top" class="thinborderTOP">&nbsp;</td>
      </tr>
	</table>
