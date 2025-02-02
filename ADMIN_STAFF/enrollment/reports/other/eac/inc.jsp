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
        <td background="../../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="140" bgcolor="#a9b9d1" align="center" class="tabFont">Print/View Schedule</td>
        <td background="../../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="140" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./eac_exam_sched_main.jsp');">Print/View Schedule</a></td>
        <td background="../../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        
<%if(iPgIndex == 2){%>
        <td background="../../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="90" bgcolor="#a9b9d1" align="center" class="tabFont">Set Schedule</td>
        <td background="../../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="90" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./create_sched.jsp');">Set Schedule</a></td>
        <td background="../../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
<%if(iPgIndex == 3){%>
        <td background="../../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="80" bgcolor="#a9b9d1" align="center" class="tabFont">Set Subject</td>
        <td background="../../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="80" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./create_subject.jsp');">Set Subject</a></td>
        <td background="../../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
<%if(iPgIndex == 4){%>
        <td background="../../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="70" bgcolor="#a9b9d1" align="center" class="tabFont">Set Room</td>
        <td background="../../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="70" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./create_room.jsp');">Set Room</a></td>
        <td background="../../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
<%if(iPgIndex == 5){%>
        <td background="../../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Auto Create Sched</td>
        <td background="../../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./auto_sched.jsp');">Auto Create Sched</a></td>
        <td background="../../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
<%if(iPgIndex == 6){%>
        <td background="../../../../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Manual Create Sched</td>
        <td background="../../../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="javascript:LinkTo('./manual_sched.jsp');">Manual Create Sched</a></td>
        <td background="../../../../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
      </tr>
	</table>
