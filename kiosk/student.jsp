<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	
	//if(
	
	
	String strErrMsg = null; String strTemp = null;
	
	Vector vStudInfo = null; String strSchoolName = null; String strSchoolAddr = null;
	
	//// Summary information.. 
	Vector vSummaryInfo = new Vector();
	 
	
	if(WI.fillTextValue("i_").length() == 0) 
		strErrMsg = "Error in getting required parameter.";
	else {
		try	{
			dbOP = new DBOperation();
			kiosk.Student studentKiosk = new kiosk.Student();
			if(!studentKiosk.authenticateRequest(dbOP, request))
				strErrMsg = studentKiosk.getErrMsg();
			else 
			{//authenticated.. 
				//request.getSession(false).setAttribute("id_","06-0471-142");
				vStudInfo = studentKiosk.getBasicStudInfo(dbOP, request);
				if(vStudInfo == null)
					strErrMsg = studentKiosk.getErrMsg();
				else {
					strTemp = "select SCHOOL_NAME,SCHOOL_ADDRESS from SYS_INFO";
					java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
					rs.next();
					strSchoolName = rs.getString(1);
					strSchoolAddr = rs.getString(2);
					rs.close();
					
					//get other summary information.. 
					vSummaryInfo = studentKiosk.getSummary(dbOP, request);
					if(vSummaryInfo == null)
						strErrMsg = studentKiosk.getErrMsg();
				}
			} 
			dbOP.cleanUP();
			dbOP = null;
		}
		catch(Exception exp) {
			exp.printStackTrace();
			strErrMsg = "error in opening connection.";
		}
	}
		
if(dbOP != null)
	dbOP.cleanUP();

if(vStudInfo == null && strErrMsg == null)
	strErrMsg = "Error in processing request. Please close this window and login again.";

if(strErrMsg != null) {%>
<p style="font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:red;">
<%=strErrMsg%>
</p>
<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/maintenancelinkscss.css".css".css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css".css".css" rel="stylesheet" type="text/css">
<style>
.mainMsgPane {
	height: 400px; overflow: auto; border: inset black 1px;
}
.extendedMsgPane {
	height: 175px; overflow: auto; border: inset black 1px;
}
pre {
white-space: -moz-pre-wrap; /* Mozilla, supported since 1999 */
white-space: -pre-wrap; /* Opera 4 - 6 */
white-space: -o-pre-wrap; /* Opera 7 */
white-space: pre-wrap; /* CSS3 - Text module (Candidate Recommendation) http://www.w3.org/TR/css3-text/#white-space */
word-wrap: break-word; /* IE 5.5+ */
}
</style>

</head>
<script language="JavaScript" src="../Ajax/ajax.js"></script>
<script language="JavaScript" src="../jscript/common.js"></script>
<script language="javascript">
function loadInfo(strMethodRef, lblRef, strInfoIndex) {
	this.setToDefault();
	
	var objMsgInput;
	if(lblRef == 1) {
		objMsgInput = document.getElementById("lbl_mainMsg");
		document.getElementById("lbl_extendedMsg").innerHTML = "...";
	}
	else 
		objMsgInput = document.getElementById("lbl_extendedMsg");
	
	this.InitXmlHttpObject2(objMsgInput, 2, "<img src='../Ajax/ajax-loader_big_black.gif'>");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../Ajax/AjaxInterface.jsp?box_type=1&methodRef="+strMethodRef;
	if(lblRef == 2)
		strURL += "&info_index="+strInfoIndex;
	this.processRequest(strURL);
}
function ShowMessage(strInfoIndex) {
	return loadInfo(406, 2, strInfoIndex);
}
function loadCourseEval() {
	this.resizePane();
	var objMsgInput = document.getElementById("lbl_mainMsg");
	var iDiv = document.getElementById('div_mainMsg');
	resizePane();	
	var iHeight = iDiv.offsetHeight-5;
 	
 	objMsgInput.innerHTML = "<iframe name='main_frame' height= '"+iHeight+"' id='main_frame' "+
													"width='99%' src='course_eval.jsp?my_home=1'></iframe>";
}
/** Ajax 2 for loading installment payment **/
var xmlHttp2          = null;
var objInstallmentPmt = null;
function loadInstallmentPmt() {
	objInstallmentPmt = document.getElementById("lbl_installmentPmt");
	try {// Firefox, Opera 8.0+, Safari
	  xmlHttp2=new XMLHttpRequest();
  	}
	catch (e){// Internet Explorer
		try {
			xmlHttp2=new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch (e) {
			xmlHttp2=new ActiveXObject("Microsoft.XMLHTTP");
		}
	}
	//this.InitXmlHttpObject2(objMsgInput, 2, "<img src='../Ajax/ajax-loader_small_black.gif'>");//I want to get innerHTML in this.retObj
	if(xmlHttp2 == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../Ajax/AjaxInterface.jsp?methodRef=402";
	xmlHttp2.onreadystatechange=stateChangedLocal;
	xmlHttp2.open("GET",strURL,true);
	xmlHttp2.send(null);
}
function stateChangedLocal() {
	if (xmlHttp2.readyState==4) {
          if (!xmlHttp2.status == 200) {//bad request.
            objInstallmentPmt.innerHTML = "Connection to server is lost";
            return;
          }

		//alert(xmlHttp.responseText); -- uncomment this to view error/exception...
		var retInfo = xmlHttp2.responseText;
		if(retInfo.indexOf("Error Msg :") == 0) {
			alert(retInfo);
			objInstallmentPmt.innerHTML = "Error in processing.";
			return;
		}
		objInstallmentPmt.innerHTML = retInfo;		
	}
	else {
		objInstallmentPmt.innerHTML = "<img src='../Ajax/ajax-loader_small_black.gif'>";
	}
}
/**** end of Ajax 2 loading the installment payment ****/

function Logout() {
	location = "./kiosk.jsp";
}

function setToDefault(){
	var iMainPane = document.getElementById('div_mainMsg');
	var iExtPane = document.getElementById('div_extendedMsg');
	
	iMainPane.style.height = 325;
	iExtPane.style.height = 250;
}

function resizePane(){
	var iMainPane = document.getElementById('div_mainMsg');
	var iExtPane = document.getElementById('div_extendedMsg');
	
	iMainPane.style.height = 575;
	iExtPane.style.height = 0;
}

</script>

<body topmargin="0" leftmargin="0" onLoad="loadInfo(401, 1);loadInstallmentPmt();">

<table width="100%" height="80" border="0" cellpadding="0" cellspacing="0" bgcolor="#006599">
  <tr valign="top"> 
    <td><img src="./kiosk.jpg"><br>
	&nbsp;<font style="font-size:15px; font-weight:bold; color:#10CCFC"><%=strSchoolName%></font><br>
	&nbsp;<font style="font-size:10px; font-weight:bold; color:#FFFFFF"><%=strSchoolAddr%></font>
	
	</td>
    <td align="right"><img src="./sa_logo.jpg">&nbsp;&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="1" cellspacing="1" >
  <tr> 
    <td width="63%" rowspan="2" valign="top" bgcolor="#80BCBC">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr> 
			  <td height="22" valign="top">
<div class="mainMsgPane" id="div_mainMsg">
	<label id="lbl_mainMsg">...</label>
</div>
			  </td>
			</tr>
      	</table>
<div class="extendedMsgPane" id="div_extendedMsg">
	<label id="lbl_extendedMsg">...</label>
</div>

<!--		
				  <table width="100%" border="0" cellspacing="0" cellpadding="0">
			
			<tr> 
			  <td height="22" colspan="2" bgcolor="#FF6600"><div align="center"><strong><font color="#FFFFFF">::: 
				  <u> VIOLATIONS &amp; CONFLICTS</u> ::::</font></strong></div></td>
			</tr>
			<tr> 
			  <td width="3%" height="22" bgcolor="#CBE4E4">&nbsp;</td>
			  <td width="97%" bgcolor="#CBE4E4"><font size="1">1.)</font></td>
			</tr>
			<tr> 
			  <td height="22" bgcolor="#E6F2F2">&nbsp;</td>
			  <td height="22" bgcolor="#E6F2F2"><font size="1">2.)</font></td>
			</tr>
			<tr> 
			  <td height="22" bgcolor="#CBE4E4">&nbsp;</td>
			  <td height="22" bgcolor="#CBE4E4"><font size="1">3.)</font></td>
			</tr>
			<tr>
			  <td height="22" bgcolor="#E6F2F2">&nbsp;</td>
			  <td height="22" bgcolor="#E6F2F2"><font size="1">4.)</font></td>
			</tr>
		  </table>
-->		  
    </td>
    <td width="37%" height="100" valign="top" bgcolor="#2A8FBD" align="center">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="33%" rowspan="6"><img src="../upload_img/<%=((String)vStudInfo.elementAt(1)).toUpperCase()%>.jpg" width="109" height="108" border="1"></td>
          <td width="67%" height="22"> <font color="#FFFFFF"><strong><%=vStudInfo.elementAt(2)%></strong></font></td>
        </tr>
        <tr> 
          <td height="22"><font color="#FFFFFF"><%=vStudInfo.elementAt(3)%></font></td>
        </tr>
<%if(vStudInfo.elementAt(4) != null){%>
        <tr> 
          <td height="22"><font color="#FFFFFF"><%=vStudInfo.elementAt(4)%></font></td>
        </tr>
<%}
String[] astrTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
if(vStudInfo.elementAt(8) != null){//Year Level.
String[] astrConvertYrLevel = {"","First Yr","Second Yr","Third Yr","Fourth Yr","Fifth Yr","Sixth Yr","Seventh Yr"};%>
        <tr> 
          <td height="22"><font color="#FFFFFF"><%=astrConvertYrLevel[Integer.parseInt((String)vStudInfo.elementAt(8))]%></font></td>
        </tr>
<%}%>
        <tr> 
          <td height="22"><font color="#FFFFFF"><%=vStudInfo.elementAt(12)%></font></td>
        </tr>
        <tr> 
          <td height="22"><font color="#FFFFFF"><strong>SY/Term Set in System: <%=astrTerm[Integer.parseInt((String)vStudInfo.elementAt(11))]%>, <%=vStudInfo.elementAt(9)%> - <%=((String)vStudInfo.elementAt(10)).substring(2)%></strong></font></td>
        </tr>
      </table>
      
	  	<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr bgcolor="#E28A12"> 
          <td height="22" colspan="3"><div align="center"><strong><font color="#FFFFFF">::: 
              <u> SUMMARY INFORMATION </u>::::</font></strong></div></td>
        </tr>
        <tr onClick="loadInfo(400, 1);">
          <td height="30">&nbsp;</td>
          <td colspan="2" style="font-weight:bold; color:#FFFFFF; font-size:17px">
		   Enrolled SY/Term: <%=astrTerm[Integer.parseInt((String)vStudInfo.elementAt(7))]%>, <%=vStudInfo.elementAt(5)%> - <%=((String)vStudInfo.elementAt(6)).substring(2)%>		  </td>
          </tr>
        <tr onClick="loadInfo(400, 1);"> 
          <td width="3%" height="30">&nbsp;</td>
          <td style="font-weight:bold; color:#003300; font-size:17px"><u>Installment Information:</u></td>
          <td width="29%" style="font-weight:bold; color:#003300; font-size:17px"><font color="#FFFFFF"><a href="#">View Ledger</a></font></td>
        </tr>
        <tr> 
          <td height="20">&nbsp;</td>
          <td colspan="2">
		  <label id="lbl_installmentPmt">...</label>		  </td>
        </tr>
        <tr onClick="loadInfo(401, 1);">
          <td>&nbsp;</td>
          <td style="font-weight:bold; color:#003300; font-size:17px">Grade Information :</td>
          <td height="30" style="font-weight:bold; color:#003300; font-size:17px"><a href="#">View Grade</a></td>
        </tr>
        <tr onClick="loadCourseEval();">
          <td>&nbsp;</td>
          <td style="font-weight:bold; color:#003300; font-size:17px">Course Evaluation :</td>
          <td height="30" style="font-weight:bold; color:#003300; font-size:17px"><a href="#">View</a></td>
        </tr>
<!--
        <tr> 
          <td height="20">&nbsp;</td>
          <td colspan="2"><font color="#003300">eWallet: <%=vSummaryInfo.remove(0)%></font></td>
          <td><font color="#003300"><a href="#">Details</a></font></td>
        </tr>
-->
<%
strTemp = (String)vSummaryInfo.remove(0);
boolean bolShowDetail = true;

if(strTemp.equals(" Balance :")) {
	strTemp = "Not found.";
	bolShowDetail = false;
}
//System.out.println(strTemp);%>
        <tr onClick="loadInfo(403, 1);"> 
          <td height="30">&nbsp;</td>
          <td style="font-weight:bold; color:#003300; font-size:17px">Internet Usage : <b><%=strTemp%></b></td>
          <td style="font-weight:bold; color:#003300; font-size:17px"><%if(bolShowDetail) {%><a href="#">Details</a><%}%></td>
        </tr>
        <tr onClick="loadInfo(404, 1);"> 
          <td height="30">&nbsp;</td>
          <td style="font-weight:bold; color:#003300; font-size:17px"><u>Library Accounts</u></td>
          <td style="font-weight:bold; color:#003300; font-size:17px"><a href="#">Details</a></td>
        </tr>
        <tr> 
          <td height="30">&nbsp;</td>
          <td colspan="2">&nbsp;&nbsp;<font color="#003300"><%=vSummaryInfo.remove(0)%></font></td>
          </tr>
        <tr> 
          <td height="20">&nbsp;</td>
          <td colspan="2">&nbsp;&nbsp;<font color="#003300"><%=vSummaryInfo.remove(0)%></font></td>
          </tr>
<!--
        <tr>
          <td height="20">&nbsp;</td>
          <td style="color:003300">Internal Mail Messages : <%=vSummaryInfo.remove(0)%></td>
          <td><font color="#003300"><a href="javascript:loadInfo(405, 1);">Details</a></font></td>
        </tr>
        <tr>
          <td height="20">&nbsp;</td>
          <td style="color:003300">Announcements</td>
          <td><font color="#003300"><a href="#">Details</a></font></td>
        </tr>
        <tr>
          <td height="20">&nbsp;</td>
          <td style="color:003300">Violations</td>
          <td><font color="#003300"><a href="#">Details</a></font></td>
        </tr>
        <tr>
          <td height="20">&nbsp;</td>
          <td style="color:003300">Academic Performace Record </td>
          <td><font color="#003300"><a href="#">Details</a></font></td>
        </tr>
-->
        <tr>
          <td height="20">&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
      </table>
	  
	    <br>
<!--
	  <input type="button" name="lo" value="Log out" style="height:32px; width:100px; font-size:14px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"
	  onClick="Logout();">
-->
	</td>
  </tr>
</table>
</body>
</html>