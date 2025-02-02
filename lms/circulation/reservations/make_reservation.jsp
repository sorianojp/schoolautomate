<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<%@ page language="java" import="utility.*,lms.LmsUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strUserIndex  = null;
//add security here.
	try
	{
		dbOP = new DBOperation();
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

//end of authenticaion code.
String[] astrSchoolYrInfo = dbOP.getCurSchYr();
if(astrSchoolYrInfo == null) {
	strErrMsg = "School year not set";
}


	String strTemp         = null;
	LmsUtil lUtil          = new LmsUtil();
	lms.BookIssue bIssue   = new lms.BookIssue();
	Vector vLibUserInfo    = null;
	Vector vBookInfo       = null;
	String[] astrBookStat  = null;
	String strBookIndex    = null;//get from accession number.

	String strPatronTypeIndex = null;
	String strIssueCode       = null;


	Vector vBPInfo         = null;//this gives if user is allowed to issue / renew a book- borrowing parameter information.
	//if so, how many books is he allowed to issue.
	Vector vBookIssueInfo  = null;//book issue information.
	int iMaxToIssue        = 0;//max number of book can be issued to this user.

	//frist get patron's information. if status is not active, do not issue/renew book.
	if(WI.fillTextValue("user_id").length() > 0 && strErrMsg == null) {
		strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("user_id"));
		if(strUserIndex == null) {
			strErrMsg = "Patron ID : "+WI.fillTextValue("user_id")+" does not exist.";
		}
		else {
			vLibUserInfo = lUtil.getLibraryUserInfo(dbOP, strUserIndex, astrSchoolYrInfo[0], astrSchoolYrInfo[1],
				astrSchoolYrInfo[2]);
			if(vLibUserInfo == null)
				strErrMsg = lUtil.getErrMsg();
		}
	}

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		//Page action for reservation..



	}

	//I have to now get borrowing parameter information her.e
	if(vLibUserInfo != null && vLibUserInfo.size() > 0 && vLibUserInfo.elementAt(15) == null ) {//if active user.
		vBPInfo = lUtil.getUserBorrowInfo(dbOP, strUserIndex);
		if(vBPInfo == null)
			strErrMsg = lUtil.getErrMsg();
		else
			strPatronTypeIndex = (String)vBPInfo.elementAt(1);
	}

	String[] astrConvertSem   = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	String[] astrConvertYrLevel = {"N/A", "1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};

	String[] astrTime     = {"8","9","10","11","12","13","14","15","16","17","18","19","20","21"};
	String[] astrTimeDisp = {"8AM","9AM","10AM","11AM","12PM","1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM","9PM"};

%>
<body bgcolor="#D0E19D" onLoad="focusID();">
<form action="./issue.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>::::
          CIRCULATION : ISSUE PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong>
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr>
      <td width="10%" height="23"><font size="1">Patron ID</font> </td>
      <td width="13%"><input type="text" name="user_id" value="<%=WI.fillTextValue("user_id")%>"
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" size="20" maxlength="32"></td>
      <td width="10%">&nbsp;</td>
      <td width="67%"><a href="javascript:ResetPrevAction();"><img src="../../images/form_proceed.gif" border="0"></a><strong>
	  <font size="3">&nbsp;&nbsp;&nbsp;AY: <%=astrSchoolYrInfo[0]%> - <%=astrSchoolYrInfo[1]%>,
	  <%=astrConvertSem[Integer.parseInt(astrSchoolYrInfo[2])]%></font></strong></td>
    </tr>
    <tr>
      <td height="19" colspan="4"><div align="right">
          <hr size="1">
        </div></td>
    </tr>
	</table>
<%
if(vLibUserInfo != null && vLibUserInfo.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="12%" height="20"><font size="1">Patron Name</font></td>
      <td width="60%"><font size="1"><strong><%=WebInterface.formatName((String)vLibUserInfo.elementAt(2),(String)vLibUserInfo.elementAt(3),
	  		(String)vLibUserInfo.elementAt(4),4)%> (Lastname, Firstname mi.)</strong></font></td>
      <td width="28%" rowspan="6" valign="top"><img src="../../../upload_img/<%=WI.fillTextValue("user_id").toUpperCase() + "."+(String)request.getSession(false).getAttribute("image_extn")%>"
	  width="125" height="125" border="1"></td>
    </tr>
    <tr>
      <td height="20"><font size="1">Patron Type</font></td>
      <td><font size="1"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(5),"<font color=red>NOT ASSIGNED</font>")%> :::
        <%if(vLibUserInfo.elementAt(15) == null){%>
        ACTIVE
        <%}else{%>
        <font size="2" color="#FF0000">BLOCKED</font> (Can't issue/renew)
        <%}%>
        </strong></font></td>
    </tr>
    <%
if( ((String)vLibUserInfo.elementAt(0)).compareTo("1") == 0) {//student %>
    <tr>
      <td height="20"><font size="1">Course/Major</font></td>
      <td><font size="1"><strong><%=(String)vLibUserInfo.elementAt(6)%><%=WI.getStrValue((String)vLibUserInfo.elementAt(7),"/","","")%></strong></font></td>
    </tr>
    <tr>
      <td height="20"><font size="1">Year Level</font></td>
      <td valign="top"><font size="1"><strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue(vLibUserInfo.elementAt(8),"0"))]%>&nbsp;&nbsp; <a href="javascript:ShowSchedule();"><img src="../../images/schedule_circulation.gif" width="40" height="20" border="0"></a>
        </strong>click to view schedule of students</font></td>
    </tr>
    <%}else{//employee%>
    <tr>
      <td height="20"><font size="1">College/Dept</font></td>
      <td><font size="1"><strong><%=WI.getStrValue((String)vLibUserInfo.elementAt(6),"N/A")%></strong></font></td>
    </tr>
    <tr>
      <td height="20"><font size="1">Office</font></td>
      <td><font size="1"><strong><%=WI.getStrValue((String)vLibUserInfo.elementAt(5),"N/A")%></strong></font></td>
    </tr>
    <%}//faculty dept/stud course info.%>
    <tr>
      <td height="20"><font size="1">Contact Addr.</font></td>
      <td><font size="1"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(12),"Not Set")%></strong></font></td>
    </tr>
    <tr>
      <td height="20"><font size="1">Contact Nos.</font></td>
      <td><font size="1"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(13),"Not Set")%></strong></font></td>
    </tr>
    <tr>
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>::::
          CIRCULATION : RESERVATIONS PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="11%" height="20">&nbsp;Patron ID</td>
      <td width="89%">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="35"><font size="1">TOTAL RESERVATIONS AS OF <strong>$DATETODAY</strong>
        : <font color="#FF0000"><strong>$TOTAL</strong></font></font></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td height="20" bgcolor="#9FC081"><div align="center"><font size="1"><strong><font size="1">ACCESSION
          / BARCODE NO.</font></strong></font></div></td>
      <td height="20" bgcolor="#9FC081"><div align="center"><strong><font size="1">TITLE</font></strong></div></td>
      <td height="20" bgcolor="#9FC081"><div align="center"><strong><font size="1">AUTHOR</font></strong></div></td>
      <td bgcolor="#9FC081"><div align="center"><strong><font size="1">CALL NO.</font></strong></div></td>
      <td height="20" bgcolor="#9FC081"><div align="center"><strong><font size="1">AVAILABLE
          COPY</font></strong></div></td>
      <td height="20" bgcolor="#9FC081"><div align="center"><strong><font size="1">RESERVATION
          DATE</font></strong></div></td>
      <td height="20" bgcolor="#9FC081"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
    </tr>
    <tr>
      <td width="11%" height="27">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td width="13%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="8%"><div align="center"><font size="1">Pending</font></div></td>
    </tr>
    <tr>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td> <div align="center"><font size="1">&nbsp;Ready</font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="center"><font size="1">Expired</font></div></td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
