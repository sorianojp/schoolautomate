<style type="text/css">
a:hover {
	font-weight: bolder;
}
a:link {
	color: #FFFFFF;
}
a:active {
	color: #FFFFFF;
}
a:visited {
	color: #FFFFFF;
}</style>
<%
int iPgIndex = Integer.parseInt(request.getParameter("pgIndex"));
 %>    <table border="0" cellpadding="0" cellspacing="0" bgcolor="#D2AE72" height="25">
      <tr>		
<%if(iPgIndex == 1){%>
        <td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="120" bgcolor="#FFFFFF" align="center" class="tabFont">Project Todo</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="project_todo.jsp?pgIndex=1">Project Todo</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}

if(iPgIndex == 2){%>
        <td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="100" bgcolor="#FFFFFF" align="center" class="tabFont">Clients</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="100" bgcolor="#00468C" align="center"><a href="update_clients.jsp?pgIndex=2">Clients</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}

if(iPgIndex == 3){%>
        <td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="100" bgcolor="#FFFFFF" align="center" class="tabFont">Projects</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="100" bgcolor="#00468C" align="center"><a href="update_projects.jsp?pgIndex=3&is_main=1">Projects</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}

if(iPgIndex == 4){%>
        <td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="160" bgcolor="#FFFFFF" align="center" class="tabFont">Client-Project Mapping</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="160" bgcolor="#00468C" align="center"><a href="client_project_mapping.jsp?pgIndex=4">Client-Project Mapping</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}

if(iPgIndex == 5){%>
        <td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="100" bgcolor="#FFFFFF" align="center" class="tabFont">Manpower</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="100" bgcolor="#00468C" align="center"><a href="update_manpower.jsp?pgIndex=5">Manpower</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}

if(iPgIndex == 6){%>
        <td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="60" bgcolor="#FFFFFF" align="center" class="tabFont">ESS</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="60" bgcolor="#00468C" align="center"><a href="employee_todo.jsp?pgIndex=6">ESS</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}

if(iPgIndex == 7){%>
        <td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="60" bgcolor="#FFFFFF" align="center" class="tabFont">Messages</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="60" bgcolor="#00468C" align="center"><a href="messages.jsp?pgIndex=7">Messages</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>

	</tr>
</table>
