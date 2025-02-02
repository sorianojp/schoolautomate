<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function goToNextSearchPage()
{
	document.rlisting.submit();
}

function ReloadPage()
{
	document.rlisting.submit();
}

function PrintPg()
{
	var dispTypeIndex = document.rlisting.disp_type.selectedIndex;//alert(dispTypeIndex);
	if(dispTypeIndex ==0) // not selected at all.
	{
		alert("Please select a room list type.");
		return;
	}
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var pgLoc = "";
		var roomTypeCon = "";
		if(dispTypeIndex ==2)
			roomTypeCon = "&room_type="+escape(document.rlisting.room_type[document.rlisting.room_type.selectedIndex].value);
		else if(dispTypeIndex ==3)
			roomTypeCon += "&room_location="+escape(document.rlisting.room_location[document.rlisting.room_location.selectedIndex].value);

		if(dispTypeIndex == 1) //all room type.
			var pgLoc = "./room_listing_print.jsp?disp_type=1&dtypename="+
			escape(document.rlisting.disp_type[document.rlisting.disp_type.selectedIndex].text);
		else if(dispTypeIndex ==2)
			var pgLoc = "./room_listing_print.jsp?disp_type=2&dtypename="+
			escape(document.rlisting.disp_type[document.rlisting.disp_type.selectedIndex].text)+roomTypeCon
		else if(dispTypeIndex == 3)
			var pgLoc = "./room_listing_print.jsp?disp_type=3&dtypename="+
				escape(document.rlisting.disp_type[document.rlisting.disp_type.selectedIndex].text)+roomTypeCon

		var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.EnrollmentRoomMonitor,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-ROOMS MONITORING-rooms listing","room_listing.jsp");
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
														"Enrollment","ROOMS MONITORING",request.getRemoteAddr(),
														"room_listing.jsp");
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

EnrollmentRoomMonitor RM = new EnrollmentRoomMonitor();
int iSearchResult = 0;
//get all levels created.
Vector vRetResult = new Vector();
if(request.getParameter("disp_type") != null && request.getParameter("disp_type").compareTo("0") != 0)
	vRetResult = RM.viewRoomList(dbOP,request, false);//bolPrint = false, print = true, only in the print page.
iSearchResult = RM.iSearchResult;
%>
<form action="./room_listing.jsp" method="post" name="rlisting">
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF" ><strong>::::
          ROOM LISTINGS PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%">List rooms by </td>
      <td colspan="2"> <select name="disp_type" onChange="ReloadPage();">
          <option value="0">Select a Type</option>
          <%
strTemp = WI.fillTextValue("disp_type");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>All rooms</option>
          <%}else{%>
          <option value="1">All rooms</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Room type</option>
          <%}else{%>
          <option value="2">Room type</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Room location</option>
          <%}else{%>
          <option value="3">Room location</option>
          <%}%>
        </select> 
        <%
if(strTemp.compareTo("2") ==0)
{%>
        Room Type: 
        <select name="room_type" onChange="ReloadPage();">
          <option value="0">Select a Type</option>
          <%=dbOP.loadComboDISTINCT("E_ROOM_TYPE.TYPE","E_ROOM_TYPE.TYPE"," from E_ROOM_TYPE where IS_DEL=0 order by E_ROOM_TYPE.TYPE asc",WI.fillTextValue("room_type") , false)%> 
        </select> 
        <%}if(strTemp.compareTo("3") ==0) {%>
        Building: 
        <select name="room_location" onChange="ReloadPage();">
          <option value="0">Select a Location</option>
          <%=dbOP.loadComboDISTINCT("E_ROOM_DETAIL.LOCATION","E_ROOM_DETAIL.LOCATION"," from E_ROOM_DETAIL where IS_DEL=0 order by E_ROOM_DETAIL.location asc",WI.fillTextValue("room_location"), false)%> 
        </select>
        Floor: 
        <select name="floor" onChange="ReloadPage();">
          <option value="0">All floors</option>
          <%=dbOP.loadComboDISTINCT("E_ROOM_DETAIL.FLOOR","E_ROOM_DETAIL.FLOOR"," from E_ROOM_DETAIL where IS_DEL=0 and E_ROOM_DETAIL.location="+
					WI.getInsertValueForDB(request.getParameter("room_location"),true,"'0'")+" order by E_ROOM_DETAIL.floor asc",WI.fillTextValue("floor") , false)%> 
        </select> 
        <%}%>
      </td>
    </tr>
    <tr> 
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" align="right"> 
        <%if(vRetResult != null && vRetResult.size() > 0)
{%>
        <a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print listing of rooms with details</font></td>
      <%}%>
    </tr>
  </table>
  <%
if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="41%" ><font size="2" face="Verdana, Arial, Helvetica, sans-serif">TOTAL
        ROOMS :<strong><%=iSearchResult%></strong> - showing(<%=RM.strDispRange%>)</font></td>
      <td width="30%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/RM.defSearchSize;
		if(iSearchResult % RM.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Jump
          To page: </font>
          <select name="jumpto" onChange="goToNextSearchPage();">
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
        </div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="15" colspan="2"><div align="center"><font size="1"><strong>LOCATION</strong></font></div>
        <div align="center"><font size="1"></font></div></td>
      <td width="6%" rowspan="2"><div align="center"><font size="1"><strong>ROOM 
          #</strong></font></div></td>
      <td width="6%" rowspan="2"><div align="center"><strong><font size="1">LAST 
          INSPECTION </font></strong></div></td>
      <td width="17%" rowspan="2"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="11%" rowspan="2"><div align="center"><font size="1"><strong>TYPE 
          OF ROOM</strong></font></div></td>
      <td width="15%" rowspan="2"><strong><font size="1">STATUS/REMARKS</font></strong></td>
      <td width="15%" rowspan="2" align="center"><strong><font size="1">FOR SUBJECT 
        ASSIGNMENT</font></strong></td>
      <td width="15%" rowspan="2"><div align="center"><strong><font size="1">CHECK 
          ROOM CONFLICT DURING ROOM ASSIGNMENT</font></strong></div></td>
      <td height="15" colspan="3"><div align="center"><font size="1"><strong>CAPACITY<br>
          (no. of students)</strong></font></div></td>
    </tr>
    <tr > 
      <td width="15%"><div align="center"><font size="1"><strong>BUILDING</strong></font></div></td>
      <td width="5%" height="12"><div align="center"><font size="1"><strong>FLOOR</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>REG.</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>IRREG.</strong></font></div></td>
      <td width="5%" align="center"><font size="1"><strong>TOTAL</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
    <tr > 
      <td><%=(String)vRetResult.elementAt(i+6)%></td>
      <td height="25"><%=(String)vRetResult.elementAt(i+7)%></td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <td><%=(String)vRetResult.elementAt(i+2)%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+9),"&nbsp;")%></td>
      <td align="center"> <% if(((String)vRetResult.elementAt(i+11)).compareTo("1") ==0)
	  {%> <img src="../../../images/x.gif" width="12" height="14"> 
        <%}else{%> <img src="../../../images/tick.gif"> <%}%> </td>
      <td align="center"> <% if(((String)vRetResult.elementAt(i+12)).compareTo("1") ==0)
	  {%> <img src="../../../images/x.gif" width="13" height="14"> 
        <%}%>
        &nbsp; </td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+3),"&nbsp")%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp")%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+5),"&nbsp")%></td>
    </tr>
    <%
i = i+13;
}//end of loop %>
  </table>
  <%}//end of displaying %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%dbOP.cleanUP();%>
