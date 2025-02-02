<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function SaveInput()
{
	document.form_search.loc.value=document.form_search.location[document.form_search.location.selectedIndex].value;
	document.form_search.acc_type.value=document.form_search.account_type[document.form_search.account_type.selectedIndex].value;
	document.form_search.s_by.value=document.form_search.sort_by[document.form_search.sort_by.selectedIndex].value;
	document.form_search.s_by_con.value=document.form_search.sort_by_con[document.form_search.sort_by_con.selectedIndex].value;
	document.form_search.r_no.value=document.form_search.room_no.value;
	document.form_search.id_num.value=document.form_search.id_number.value;
	document.form_search.rent.value=document.form_search.rental[document.form_search.rental.selectedIndex].value;
}
function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var pgLoc = "./view_delete_print.jsp?loc="+document.form_search.loc.value+
		"&s_by="+document.form_search.s_by.value+"&s_by_con="+document.form_search.s_by_con.value+"&r_no="+
		escape(document.form_search.r_no.value)+"&rent="+document.form_search.rent.value+"&id_num="+document.form_search.id_num.value+
		"&acc_type="+document.form_search.acc_type.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function ReloadPage()
{
	document.form_search.submit();
}
function DeleteRecord(strUserId)
{
	location="./occ_delete.jsp?stud_id="+escape(strUserId);
}
function ViewOccupant(strUserId)
{
	//open a new window.
	var pgLoc = "./view_occ.jsp?view=1&stud_id="+escape(strUserId);
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.HostelManagement,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-OCCUPANCY MAINTENANCE- View/Delete occupant","view_delete.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Hostel Management","OCCUPANCY MAINTENANCE",request.getRemoteAddr(),
														"view_delete.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

HostelManagement HM = new HostelManagement();
Vector vRetResult = null;
int iSearchResult = 0;
if(WI.fillTextValue("reloadPage").length() > 0)
{
	vRetResult = HM.searchOccupant(dbOP, request,false);
	if(vRetResult == null)
		strErrMsg = HM.getErrMsg();
	else
		iSearchResult = HM.iSearchResult;
}

if(strErrMsg == null) strErrMsg = "";
%>
<form name="form_search" action="./view_delete.jsp" method="post">
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          OCCUPANCY MAINTENANCE - VIEW/DELETE PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Location/Name</td>
      <td width="30%"><select name="location">
          <option value="0">Any</option>
          <%=dbOP.loadCombo("LOCATION_INDEX","LOCATION"," from FA_STUD_SCHFAC_DORM_LOC where is_del=0 order by LOCATION asc", request.getParameter("location"), false)%>
        </select> </td>
      <td width="16%">Room # / House # </td>
      <td width="34%"><input name="room_no" type="text" size="16" value="<%=WI.fillTextValue("room_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Rental <font size="1">(per month)</font></td>
      <td><select name="rental">
          <option value="0">Any</option>
          <%
strTemp = WI.fillTextValue("rental");
if(strTemp.compareTo("1000") ==0){%>
          <option value="1000" selected>Below 1000</option>
          <%}else{%>
          <option value="1000">Below 1000</option>
          <%}if(strTemp.compareTo("2000") ==0){%>
          <option value="2000" selected>Between 1000-2000</option>
          <%}else{%>
          <option value="2000">Between 1000-2000</option>
          <%}if(strTemp.compareTo("3000") ==0){%>
          <option value="3000" selected>Between 2000-3000</option>
          <%}else{%>
          <option value="3000">Between 2000-3000</option>
          <%}if(strTemp.compareTo("4000") == 0){%>
          <option value="4000" selected>Between 3000-4000</option>
          <%}else{%>
          <option value="4000">Between 3000-4000</option>
          <%}if(strTemp.compareTo("5000") ==0){%>
          <option value="5000" selected>Between 4000-5000</option>
          <%}else{%>
          <option value="5000">Between 4000-5000</option>
          <%}if(strTemp.compareTo("000") ==0){%>
          <option value="000" selected>Above 5000</option>
          <%}else{%>
          <option value="000">Above 5000</option>
          <%}%>
        </select></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Account Type </td>
      <td><select name="account_type">
	  <option value="0">Any</option>
<%
strTemp = WI.fillTextValue("account_type");
if(strTemp.compareTo("Student") ==0){%>
<option value="Student" selected>Student</option>
<%}else{%>
<option value="Student">Student</option>
<%}if(strTemp.compareTo("Employee") == 0){%>
<option value="Employee" selected>Employee</option>
<%}else{%>
<option value="Employee">Employee</option>
<%}%>
        </select></td>
      <td>ID Number </td>
      <td><input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Sort by</td>
      <td><select name="sort_by">
          <option value="0">Not Sorted</option>
          <%
strTemp = WI.fillTextValue("sort_by");
if(strTemp.compareTo("room_no") ==0){%>
          <option value="room_no" selected>Room #</option>
          <%}else{%>
          <option value="room_no">Room #</option>
          <%}if(strTemp.compareTo("room_status") ==0){%>
          <option value="id_number" selected>ID Number</option>
          <%}else{%>
          <option value="id_number">ID Number</option>
          <%}if(strTemp.compareTo("rental") ==0){%>
          <option value="rental" selected>Rental</option>
          <%}else{%>
          <option value="rental">Rental</option>
          <%}%>
        </select> <select name="sort_by_con">
          <option value=" asc">Ascending</option>
          <%
strTemp = WI.fillTextValue("sort_by_con");
if(strTemp.compareTo(" desc") ==0){%>
          <option value=" desc" selected>Descending</option>
          <%}else{%>
          <option value=" desc">Descending</option>
          <%}%>
        </select></td>
      <td colspan="2"><input name="image" type="image" onClick="SaveInput();" src="../../../images/search.gif">
        <font size="1">Click to Search</font></td>
    </tr>
  </table>
  <%
if(vRetResult != null && vRetResult.size() >0)//7 in one set ;-)
{%>
<table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td><div align="right"><a href="javascript:PrintPg();" title="Click to print"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
          <font size="1">click to print result list &nbsp;&nbsp;</font></div></td>
    </tr>
  </table>

<table width="100%" border="0" bgcolor="#FFFFFF">
<tr>
      <td width="66%" ><b> Total Occupantss : <%=iSearchResult%> - Showing(<%=HM.strDispRange%>)</b></td>
      <td width="34%" align="right">
	  <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/HM.defSearchSize;
		if(iSearchResult % HM.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
		Jump To page:
          <select name="jumpto" onChange="ReloadPage();">

		<%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
					<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}else{%>
					<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%
					}
			}
			%>
			 </select>

		<%}%>

        </td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="10" bgcolor="#B9B292"><div align="center">LIST
          OF OCCUPANTS</div></td>
    </tr>
    <tr>
      <td width="10%" ><div align="center"><strong><font size="1">ID NUMBER</font></strong></div></td>
      <td width="25%" height="24" ><div align="center"><font size="1"><strong>ACCOUNT
          NAME </strong></font></div></td>
      <td width="6%" ><div align="center"><font size="1"><strong>ACCOUNT TYPE
          </strong></font></div></td>
      <td width="8%" ><div align="center"><font size="1"><strong>DATE OF OCCUPANCY</strong></font></div></td>
      <td width="10%" ><div align="center"><font size="1"><strong>LOCATION/ NAME</strong></font></div></td>
      <td width="8%" ><div align="center"><font size="1"><strong>ROOM#/ HOUSE#</strong></font></div></td>
      <td width="8%" ><div align="center"><strong><font size="1">RENTAL </font></strong></div></td>
      <td width="10%" ><div align="center"><font size="1"><strong>OUTSTANDING
          BALANCE </strong></font></div></td>
      <td width="7%" align="center"><font size="1"><strong>VIEW</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
for(int i=0 ; i< vRetResult.size();++i){%>
    <tr>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i))%></td>
      <td height="25" >&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td ><%=(String)vRetResult.elementAt(i+2)%></td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+3))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+4))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+5))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+6))%></td>
      <td >&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
      <td align="center"><a href='javascript:ViewOccupant("<%=(String)vRetResult.elementAt(i)%>");' title="Click to view occupant information">
        <img src="../../../images/view.gif" border="0"></a> </td>
      <td align="center">
<%if(iAccessLevel ==2){%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");' title="Click to delete occupant">
        <img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized<%}%>		</td>
    </tr>
    <%
i = i+8;
}%>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:PrintPg();" title="Click to print"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
        <font size="1">click to print result list</font></td>
    </tr>
  </table>
<%}else if(WI.fillTextValue("reloadPage").length() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td> <font size="3">&nbsp;&nbsp;&nbsp; No Occupant(s) found</font></td>
	</tr>
	</table>

<%}//only if there are rooms.
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="loc" value="<%=WI.fillTextValue("loc")%>">
<input type="hidden" name="s_by" value="<%=WI.fillTextValue("s_by")%>">
<input type="hidden" name="s_by_con" value="<%=WI.fillTextValue("s_by_con")%>">
<input type="hidden" name="r_no" value="<%=WI.fillTextValue("r_no")%>">
<input type="hidden" name="rent" value="<%=WI.fillTextValue("rent")%>">
<input type="hidden" name="id_num" value="<%=WI.fillTextValue("id_number")%>">
<input type="hidden" name="acc_type" value="<%=WI.fillTextValue("acc_type")%>">

<input name="reloadPage" value="0" type="hidden">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="user_index">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
