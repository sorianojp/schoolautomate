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
 %>    <table border="0" cellpadding="0" cellspacing="0" bgcolor="#D2AE72" height="30" width="100%">
      <tr>		
<%if(iPgIndex == 0){%>
        <td width="20%" bgcolor="#FF0000" align="center" class="thinborderBOTTOM"><strong><font color="#FFFFFF">Exclude Subject</font></strong></td>
<%}else{%>
        <td width="20%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="exclude_subject.jsp?pgIndex=0">
			<strong><font color="#000000">Exclude Subject</font></strong></a></td>		
<%}if(iPgIndex == 1){%>
        <td width="20%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">Exclude Student</font></strong></td>
<%}else{%>
        <td width="20%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="exclude_student.jsp?pgIndex=1">
			<strong><font color="#000000">Exclude Student</font></strong></a></td>
<%}
if(iPgIndex == 2){%>
        <td width="20%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">Copy Excluded Student-Subject</font></strong></td>
<%}else{%>
        <td width="20%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="copy_exclude_subject_student.jsp?pgIndex=2">
			<strong><font color="#000000">Copy Excluded Student-Subject</font></strong></a></td>
<%}
if(iPgIndex == 3){%>
        <td width="20%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">Set Auto Apply Discount</font></strong></td>
        <%}else{%>
        <td width="20%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="auto_apply_disc.jsp?pgIndex=3">
			<strong><font color="#000000">Set Auto Apply Discount</font></strong></a></td>
        <%}%>
		
	</tr>
</table>
