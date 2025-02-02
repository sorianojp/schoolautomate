<%
int iPgIndex      = Integer.parseInt(request.getParameter("pgIndex"));
String strUserID  = request.getParameter("user_id");
boolean bolMyHome = false;
String strMyHome  = request.getParameter("myhome");
if(strMyHome == null)
	strMyHome = "";

if(strMyHome.equals("1"))
	bolMyHome = true;
	
if(strUserID == null)
	strUserID = "";
%>    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
<%if(iPgIndex == 1){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="60" bgcolor="#a9b9d1" align="center" class="tabFont">Summary</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="60" bgcolor="#000000" align="center"><a href="./patron_summary.jsp?user_id=<%=strUserID%>&myhome=<%=strMyHome%>">Summary</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        <td width="2">&nbsp;</td>
<%if(iPgIndex == 2){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="70" bgcolor="#a9b9d1" align="center" class="tabFont">Circulation</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="70" bgcolor="#000000" align="center"><a href="./patron_circulation.jsp?user_id=<%=strUserID%>&myhome=<%=strMyHome%>">Circulation</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        <td width="2">&nbsp;</td>
<%if(iPgIndex == 4){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="95" bgcolor="#a9b9d1" align="center" class="tabFont">Fine Information</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="95" bgcolor="#000000" align="center"><a href="./patron_fine.jsp?user_id=<%=strUserID%>&myhome=<%=strMyHome%>">Fine Information</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        <td width="2">&nbsp;</td>
<%if(iPgIndex == 5){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="50" bgcolor="#a9b9d1" align="center" class="tabFont">Messages</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="50" bgcolor="#000000" align="center"><a href="./patron_msg.jsp?user_id=<%=strUserID%>&myhome=<%=strMyHome%>">Messages</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        <td width="2">&nbsp;</td>
<%if(iPgIndex == 7){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="50" bgcolor="#a9b9d1" align="center" class="tabFont">Per. Info</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="50" bgcolor="#000000" align="center"><a href="./patron_pinfo.jsp?user_id=<%=strUserID%>&myhome=<%=strMyHome%>">Per. Info</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        <td width="2">&nbsp;</td>
<%if(iPgIndex == 3 && bolMyHome){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="70" bgcolor="#a9b9d1" align="center" class="tabFont">My Booklist</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else if(bolMyHome){%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="70" bgcolor="#000000" align="center"><a href="../home/my_collection.jsp" target="_blank">My Booklist</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        <td width="2">&nbsp;</td>
<%if(iPgIndex == 6 && bolMyHome){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="55" bgcolor="#a9b9d1" align="center" class="tabFont">Chng Pwd </td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else if(bolMyHome){%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="55" bgcolor="#000000" align="center"><a href="../../my_home/change_password.jsp?bgcol=D0E19D&headercol=77A251&goback=1">Chng Pwd </a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>

        <td width="2">&nbsp;</td>
<%if(iPgIndex == 8){%>
        <td background="../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="70" bgcolor="#a9b9d1" align="center" class="tabFont">Lib. Attendance</td>
        <td background="../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="70" bgcolor="#000000" align="center"><a href="./patron_lib_attendance.jsp?user_id=<%=strUserID%>&myhome=<%=strMyHome%>">Lib. Attendance</a></td>
        <td background="../images/tabright.gif" width="10">&nbsp;</td>
<%}%>

        <td>&nbsp;</td>
      </tr>
      <tr>
        <td height="10" colspan="12" valign="top" class="thinborderTOP">&nbsp;</td>
      </tr>
	</table>
