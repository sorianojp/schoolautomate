<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
a:link {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:visited {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:active {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:hover {
	color:#f00;
	font-weight:700;
	}
.tabFont {
	color:#444444;
	font-weight:700;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
}
</style>
</head>
<script src="../../jscript/common.js"></script>
<script src="../../Ajax/ajax.js"></script>
<script language="javascript">
function ShowSchedule() {

}


function AjaxMapName() {
	var strCompleteName = document.form_.user_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.user_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<%@ page language="java" import="utility.*,lms.LmsUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = null;

	boolean bolShowIDInput = true;
	if(WI.fillTextValue("myhome").length() > 0)
		bolShowIDInput = false;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Circulation".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
		bolShowIDInput = false;

//end of authenticaion code.

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

	Vector vLibUserInfo = null;
	Vector vRetResult   = null;
	
	boolean bolIsBasic  = false;

	Vector vCirculationDtls = null; Vector vCirculationSetting = null; Vector vCirculationStat = null;
	Vector vCirculationMsg  = null; Vector vAnnouncement       = null;

	LmsUtil lUtil    = new LmsUtil();

	String strUserID = WI.fillTextValue("user_id");
	if(bolShowIDInput && strUserID.length() > 0 ) {
		strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("user_id"));
		if(strUserIndex == null)
			strErrMsg = "ID : "+WI.fillTextValue("user_id")+" does not exist in system.";
	}
	else if(!bolShowIDInput) {
		strUserID = (String)request.getSession(false).getAttribute("userId");
		strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	}
//// get user information.
	if(strUserIndex != null ) {
		vLibUserInfo = lUtil.getLibraryUserInfoBasic(dbOP, strUserIndex);
		
		if(vLibUserInfo == null)
			strErrMsg = lUtil.getErrMsg();
		else {
			bolIsBasic = lUtil.bolIsBasic();
		
			lms.PatronInformation pInfo = new lms.PatronInformation();
			vRetResult = pInfo.getSummary(dbOP, strUserIndex);
			if(vRetResult != null) {
				vCirculationDtls    = (Vector)vRetResult.remove(0);
				vCirculationSetting = (Vector)vRetResult.remove(0);
				vCirculationStat    = (Vector)vRetResult.remove(0);
				vCirculationMsg     = (Vector)vRetResult.remove(0);
				vAnnouncement       = (Vector)vRetResult.remove(0);
			}
		}
		/**
		else {
			lms.FineManagement fineMgmt = new lms.FineManagement();
			///if page action = 1, i must save fine.
			if(WI.fillTextValue("page_action").equals("1")) {
				strTemp = fineMgmt.payFineSingle(dbOP, strUserIndex, request);
				if(strTemp != null)
					strErrMsg = "Fine Payment successful. Payment Receipt # is "+
						"<a href='javascript:PrintReceipt("+strTemp+
						");'><font size=3>"+strTemp+"</font></a>. Click on Receipt # to print receipt";
				else
					strErrMsg = fineMgmt.getErrMsg();
			}
			vFineOutstanding = fineMgmt.getOutstandingFine(dbOP, strUserIndex);
		}**/

	}


	String[] astrConvertSem   = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	String[] astrConvertYrLevel = {"N/A", "1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};


String strMyHome = WI.fillTextValue("myhome");
%>
<body bgcolor="#D0E19D">
<form action="./patron_summary.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#77A251"><div align="center"><font color="#FFFFFF" ><strong>::::
        PATRON INFORMATION MAIN PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
</table>
<jsp:include page="./inc.jsp?pgIndex=1&user_id=<%=strUserID%>&myhome=<%=strMyHome%>"></jsp:include>

    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="10%"><font size="1">Patron ID</font></td>
        <td width="13%">
<%if(bolShowIDInput){%>
		<input type="text" name="user_id" value="<%=WI.fillTextValue("user_id")%>"
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onKeyUp="AjaxMapName();"
		onBlur="style.backgroundColor='white'" size="20" maxlength="32">
<%}else{%>
		<%=strUserID%>
<%}%>		</td>
        <td width="17%">&nbsp;&nbsp;&nbsp;
         <%if(bolShowIDInput){%><input type="submit" name="Proceed" value="Proceed >>"><%}%>		</td>
        <td width="60%">
		  		<label id="coa_info" style="position:absolute; width:500px;"></label>
		  </td>
      </tr>
		
		
      <%if(strErrMsg != null){%>
      <tr>
        <td colspan="4"><font size="3" color="#666633"><b><%=strErrMsg%></b></font></td>
      </tr>
      <%}%>
      <tr>
        <td colspan="4"><hr size="1"></td>
      </tr>
    </table>
    <%
if(vLibUserInfo != null && vLibUserInfo.size() > 0){
	boolean bolIsStud = false;
	if(vLibUserInfo.elementAt(0).equals("1"))
		bolIsStud = true;
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="12%" height="20"><font size="1">Patron Name</font></td>
      <td width="63%"><font size="1"><strong>
	  <%=WebInterface.formatName((String)vLibUserInfo.elementAt(2),(String)vLibUserInfo.elementAt(3),(String)vLibUserInfo.elementAt(4),4)%> (Lastname, Firstname mi.)</strong></font></td>
	  	<%
		if(bolIsBasic)
			strTemp = "rowspan='4'";
		else	
			strTemp = "rowspan='6'";
		%>
      <td width="25%" <%=strTemp%>  valign="top"><img src="../../upload_img/<%=WI.fillTextValue("user_id").toUpperCase() + "."+(String)request.getSession(false).getAttribute("image_extn")%>"
	  width="100" height="100" border="1"></td>
    </tr>
    <tr>
      <td height="20"><font size="1">Patron Type</font></td>
      <td><font size="1"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(5),"<font color=red>NOT ASSIGNED</font>")%> :::
        <%if(vLibUserInfo.elementAt(11) != null){%>
        <font size="2" color="#FF0000">BLOCKED STATUS</font>
        <%}%>
        </strong>
		<%if(bolIsStud) {%>
			Last SY-Term : <%=(String)vLibUserInfo.elementAt(8)%>
		<%}else if(vLibUserInfo.elementAt(8) != null){%>
			Date Resigned : <%=(String)vLibUserInfo.elementAt(8)%>
		<%}%>
		</font></td>
    </tr>
<%if(bolIsStud) {//student 
		if(!bolIsBasic){
	%>
	 <tr>
	 	
      <td height="20"><font size="1">Course/Major</font></td>
      <td><font size="1"><strong><%=(String)vLibUserInfo.elementAt(6)%></strong></font></td>
    </tr>
	 <%}%>
    <tr>
      <td height="20"><font size="1">Year Level</font></td>
		<%
		if(bolIsBasic)
			strTemp = WI.getStrValue(vLibUserInfo.elementAt(7),"&nbsp;");
		else
			strTemp = astrConvertYrLevel[Integer.parseInt(WI.getStrValue(vLibUserInfo.elementAt(7),"0"))];
		%>
      <td valign="top"><font size="1"><strong><%=strTemp%></strong>&nbsp;&nbsp; 
	  <!--<a href="javascript:ShowSchedule();"><img src="../images/schedule_circulation.gif" width="40" height="20" border="0"></a>
        click to view schedule of student--></font></td>
    </tr>
    <%}else{//employee%>
    <tr>
      <td height="20"><font size="1">College/Dept</font></td>
      <td><font size="1"><strong><%=WI.getStrValue((String)vLibUserInfo.elementAt(6),"N/A")%></strong></font></td>
    </tr>
    <tr>
      <td height="20"><font size="1">Office</font></td>
      <td><font size="1"><strong><%=WI.getStrValue((String)vLibUserInfo.elementAt(7),"N/A")%></strong></font></td>
    </tr>
    <%}//faculty dept/stud course info.%>
    <tr>
      <td height="20" valign="top"><font size="1">Contact Addr.</font></td>
      <td valign="top"><font size="1"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(10),"Not Set")%></strong></font></td>
    </tr>

    <tr>
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td colspan="2" align="center" bgcolor="#9FcFFF" class="thinborderALL" height="18"><strong>Circulation Detail</strong></td>
    <td>&nbsp;</td>
    <td colspan="2" align="center" bgcolor="#9FcFFF" class="thinborderALL"><strong>Circulation Setting</strong></td>
    <td>&nbsp;</td>
    <td colspan="2" align="center" bgcolor="#9FcFFF" class="thinborderALL"><strong>Circulation Statistics </strong></td>
  </tr>
  <tr>
    <td bgcolor="#EEEEEE" width="24%" class="thinborderBOTTOMLEFT"> Books Issued(Due now) </td>
    <td bgcolor="#EEEEEE" width="8%" class="thinborderBOTTOMLEFTRIGHT">
		<%if(vCirculationDtls != null && vCirculationDtls.size() > 0) {%>
			<%=(String)vCirculationDtls.elementAt(0)%>
		<%}else{%>xxxx<%}%>	</td>
    <td width="2%" height="18">&nbsp;</td>
    <td bgcolor="#EEEEEE" width="24%" class="thinborderBOTTOMLEFT">Max Borrow </td>
    <td bgcolor="#EEEEEE" width="8%" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationSetting != null && vCirculationSetting.size() > 0) {%>
			<%=(String)vCirculationSetting.elementAt(0)%>
	<%}else{%>xxxx<%}%>
	  </td>
    <td width="2%" height="18">&nbsp;</td>
    <td bgcolor="#EEEEEE" width="20%" class="thinborderBOTTOMLEFT">Book Issued(this mnth) </td>
    <td bgcolor="#EEEEEE" width="12%" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationStat != null && vCirculationStat.size() > 0) {%>
			<%=(String)vCirculationStat.elementAt(0)%>
	<%}else{%>xxxx<%}%>
	  </td>
  </tr>
  <tr>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT"> Overdue </td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationDtls != null && vCirculationDtls.size() > 0) {%>
	<%=(String)vCirculationDtls.elementAt(1)%>
	  <%}else{%>xxxx
	  <%}%></td>
    <td height="18">&nbsp;</td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Max Overdue </td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationSetting != null && vCirculationSetting.size() > 0) {%>
			<%=(String)vCirculationSetting.elementAt(1)%>
	<%}else{%>xxxx<%}%>
	  </td>
    <td height="18">&nbsp;</td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Total Fine(this mnth)</td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationStat != null && vCirculationStat.size() > 0) {%>
			<%=(String)vCirculationStat.elementAt(1)%>
	<%}else{%>xxxx<%}%>
	  </td>
  </tr>
  <tr>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Unpaid Fine Outstanding </td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationDtls != null && vCirculationDtls.size() > 0) {%>
			<%=(String)vCirculationDtls.elementAt(2)%>
	<%}else{%>xxxx<%}%></td>
    <td height="18">&nbsp;</td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Max Fine </td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationSetting != null && vCirculationSetting.size() > 0) {%>
			<%=(String)vCirculationSetting.elementAt(2)%>
	<%}else{%>xxxx<%}%>
	  </td>
    <td height="18">&nbsp;</td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Fine Balance</td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationStat != null && vCirculationStat.size() > 0) {%>
			<%=(String)vCirculationStat.elementAt(2)%>
	<%}else{%>xxxx<%}%>
	  </td>
  </tr>
  <tr>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Running Fine  </td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationDtls != null && vCirculationDtls.size() > 0) {%>
			<%=(String)vCirculationDtls.elementAt(3)%>
	<%}else{%>xxxx<%}%></td>
    <td height="18">&nbsp;</td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Max Reserve </td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationSetting != null && vCirculationSetting.size() > 0) {%>
			<%=(String)vCirculationSetting.elementAt(3)%>
	<%}else{%>xxxx<%}%>
	  </td>
    <td height="18">&nbsp;</td>
    <td colspan="2" bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT" align="center">Click to view Statistics Detail</td>
    </tr>
  <tr>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Tot.Reservation(Ready) </td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationDtls != null && vCirculationDtls.size() > 0) {%>
			<%=(String)vCirculationDtls.elementAt(4)%>
	<%}else{%>xxxx<%}%>
	  </td>
    <td height="18">&nbsp;</td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Reservation Priority </td>
    <td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT">
	<%if(vCirculationSetting != null && vCirculationSetting.size() > 0) {%>
			<%=(String)vCirculationSetting.elementAt(4)%>
	<%}else{%>xxxx<%}%>
	  </td>
    <td height="18">&nbsp;</td>
    <td colspan="2" bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT" align="center">&nbsp;</td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="100%">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" bgcolor="#9FcFFF" class="thinborderALL"><strong>-: Circulation Message :- </strong></td>
  </tr>
<%
if(vCirculationMsg != null)
for(int i = 0; i < vCirculationMsg.size(); ++i){%>
  <tr>
    <td height="20" class="thinborderLEFTRIGHT"><%=i + 1%>. <%=vCirculationMsg.elementAt(i)%></td>
  </tr>
<%}%>
  <tr>
    <td height="20" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
  </tr>
  <tr>
    <td width="100%">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" bgcolor="#9FcFFF" class="thinborderALL"><strong>-: Announcement :- </strong> </td>
  </tr>
<%
if(vAnnouncement != null)
for(int i = 0; i < vAnnouncement.size(); i += 2){%>
  <tr>
    <td height="20" class="thinborderLEFTRIGHT"><%=i/2 + 1%>.
		<%=vAnnouncement.elementAt(i)%> :: <%=vAnnouncement.elementAt(i + 1)%></td>
  </tr>
<%}%>
  <tr>
    <td height="20" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
  </tr>
</table>

<%}//show only if vLibUserInfo is not null%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr bgcolor="#77A251">
    <td  height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="myhome" value="<%=WI.fillTextValue("myhome")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
