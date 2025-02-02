<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
  //request.getSession(false).setAttribute("i_","415");
	//request.getSession(false).setAttribute("id_","415");
	
	String strErrMsg = null; 
	String strTemp = null;
	String strTemp2 = null;
	
	Vector vEmployeenfo = null; 
	String strSchoolName = null; 
	String strSchoolAddr = null;
	String strUserID = WI.fillTextValue("i_");
	String strUserIndex = null;
	
	if(strUserID.length() == 0)
		strUserID = (String)request.getSession(false).getAttribute("i_");

	int iNumOfNotifications	= 0;
	hr.HRNotification  hrNotification = new hr.HRNotification();
	Vector vNotifications = null;
	//// Summary information.. 
	//Vector vSummaryInfo = new Vector();
		

//	request.getSession(false).setAttribute("t_","06-0471-142");
//	request.getSession(false).setAttribute("m","06-0471-142");	
	if(strUserID.length() == 0) 
		strErrMsg = "Error in getting required parameter.";
	else {
		try	{
			dbOP = new DBOperation();
			kiosk.EmployeeKiosk empKiosk = new kiosk.EmployeeKiosk();
			if(!empKiosk.authenticateRequest(dbOP, request))
				strErrMsg = empKiosk.getErrMsg();
			else 
			{//authenticated.. 
				//request.getSession(false).setAttribute("id_","06-0471-142");
				vEmployeenfo = empKiosk.getBasicEmpInfo(dbOP, request);
				if(vEmployeenfo == null)
					strErrMsg = empKiosk.getErrMsg();
				else {
					strTemp = "select SCHOOL_NAME,SCHOOL_ADDRESS from SYS_INFO";
					java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
					rs.next();
					strSchoolName = rs.getString(1);
					strSchoolAddr = rs.getString(2);
					rs.close();
					
					//get other summary information.. 
					//vSummaryInfo = empKiosk.getSummary(dbOP, request);
					//if(vSummaryInfo == null)
					//	strErrMsg = empKiosk.getErrMsg();

				strUserIndex = (String)vEmployeenfo.elementAt(0);
				//System.out.println("strUserIndex " + strUserIndex);
				vNotifications = hrNotification.getAllNotifications(dbOP, strUserIndex);
				//System.out.println("vNotifications " + vNotifications);
				if(vNotifications == null)
					iNumOfNotifications = 0;
				}
			} 
		}
		catch(Exception exp) {
			exp.printStackTrace();
			strErrMsg = "error in opening connection.";
		}
	}
		
if(vEmployeenfo == null && strErrMsg == null)
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
	height: 320px; overflow: auto; border: inset black 1px;
}
.extendedMsgPane {
	height: 250px; overflow: auto; border: inset black 1px;
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
function loadInfo(strMethodRef, lblRef) {
	var objMsgInput;
	if(lblRef == 1) {
		objMsgInput = document.getElementById("lbl_mainMsg");
		document.getElementById("lbl_extendedMsg").innerHTML = "...";
	}
	else 
		objMsgInput = document.getElementById("lbl_extendedMsg");
	setToDefault();
	/*
	var layer = document.getElementById("div_mainMsg");
	layer.style.display = 'block';
	var iframe = document.getElementById('iframetop');
	iframe.style.display = 'block';
	iframe.style.width = layer.offsetWidth-5;	
	iframe.style.height = layer.offsetHeight-5;
	iframe.style.left = layer.offsetLeft;
	iframe.style.top = layer.offsetTop;
	alert("width " + iframe.style.width);
	alert("height " + iframe.style.height);
	alert("left " + iframe.style.left);
	alert("top " + iframe.style.top);
	*/
	
	this.InitXmlHttpObject2(objMsgInput, 2, "<img src='../Ajax/ajax-loader_big_black.gif'>");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../Ajax/AjaxInterface.jsp?box_type=1&methodRef="+strMethodRef;
	this.processRequest(strURL);
}

/** Ajax 2 for loading installment payment **/
var xmlHttp2          = null;
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

function viewSchedule(strRetLoanIndex, strCodeIndex){
	var objMsgInput = document.getElementById("lbl_extendedMsg");

	//var layer = document.getElementById('div_mainMsg');
	//layer.style.display = 'block';
	//var iframe = document.getElementById('iframetop');
	//iframe.style.display = 'block';
	//iframe.style.width = layer.offsetWidth-5;
	//iframe.style.height = layer.offsetHeight-5;
	//iframe.style.left = layer.offsetLeft;
	//iframe.style.top = layer.offsetTop;
	
	this.InitXmlHttpObject2(objMsgInput, 2, "<img src='../Ajax/ajax-loader_big_black.gif'>");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../Ajax/AjaxInterface.jsp?box_type=1&methodRef=417&r_index="+strRetLoanIndex+
							 "&cd_index="+strCodeIndex;
	this.processRequest(strURL);
}

function loadDtr(){
	var objMsgInput = document.getElementById("lbl_mainMsg");
	var iDiv = document.getElementById('div_mainMsg');
	resizePane();		
	var iHeight = iDiv.offsetHeight-5;
 	
 	lbl_mainMsg.innerHTML = "<iframe name='main_frame' height= '"+iHeight+"' id='main_frame' "+
													"width='99%' src='emp_dtr.jsp?my_home=1'></iframe>";
											
}

function loadPayslips(){
	var objMsgInput = document.getElementById("lbl_mainMsg");
	var iDiv = document.getElementById('div_mainMsg');
	resizePane();	
	var iHeight = iDiv.offsetHeight-5;
 	
 	lbl_mainMsg.innerHTML = "<iframe name='main_frame' height= '"+iHeight+"' id='main_frame' "+
													"width='99%' src='payslip.jsp?my_home=1'></iframe>";
												
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

function loadNotifications(){
	var objMsgInput = document.getElementById("lbl_mainMsg");
	var iDiv = document.getElementById('div_mainMsg');
	resizePane();		
	var iHeight = iDiv.offsetHeight-5;
 	
 	lbl_mainMsg.innerHTML = "<iframe name='main_frame' height= '"+iHeight+"' id='main_frame' "+
													"width='99%' src='../my_home/notifications.jsp?my_home=1'></iframe>";
											
}
</script>
<body topmargin="0" leftmargin="0">
<table width="100%" height="80" border="0" cellpadding="0" cellspacing="0" bgcolor="#006599">
  <tr valign="top"> 
    <td><img src="./kiosk_employee.jpg"><br>
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
				<!--
				<iframe width="0" scrolling="no" height="0" 
						frameborder="0" class="iballoonstyle" id="iframetop">
				</iframe>
				-->
				<div class="mainMsgPane" id="div_mainMsg">
					<label id="lbl_mainMsg">...</label>
				</div>

				<!--
				<iframe height="430" name="main_frame" id="main_frame" width="100%" 
				src="frame_content/login.jsp"></iframe>
				-->
			  </td>
			</tr>
    </table>
		<div class="extendedMsgPane" id="div_extendedMsg">
			<label id="lbl_extendedMsg">...</label>
		</div> 
    </td>
    <td width="37%" height="90" valign="top" bgcolor="#2A8FBD" align="center">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="33%" rowspan="6"><img src="../upload_img/<%=((String)vEmployeenfo.elementAt(1)).toUpperCase()%>.jpg" width="109" height="108" border="1"></td>
          <td width="67%" height="22"> <font color="#FFFFFF"><strong><%=vEmployeenfo.elementAt(2)%></strong></font></td>
        </tr>
        <tr> 
          <td height="22"><font color="#FFFFFF"><%=vEmployeenfo.elementAt(3)%></font></td>
        </tr>
        <tr> 
				<%
				if((String)vEmployeenfo.elementAt(4)== null || (String)vEmployeenfo.elementAt(5)== null){
					strTemp = " ";			
				}else{
					strTemp = " - ";
				}
			
				strTemp2 = WI.getStrValue((String)vEmployeenfo.elementAt(4)," ");
				strTemp2 += strTemp;
				strTemp2 += WI.getStrValue((String)vEmployeenfo.elementAt(5)," ");				
				%>
          <td height="22"><font color="#FFFFFF"><%=strTemp2%></font></td>
        </tr>
        <tr> 
          <td height="22"><font color="#FFFFFF"><%//=vEmployeenfo.elementAt(12)%></font></td>
        </tr>
        <tr> 
          <td height="22">&nbsp;</td>
        </tr>
      </table>
	  	<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr bgcolor="#E28A12"> 
          <td height="22" colspan="3" align="center"><strong><font color="#FFFFFF"> </font></strong></td>
        </tr>
        <tr onClick="loadDtr();"> 
          <td width="3%" height="30">&nbsp;</td>
          <td width="8%" style="font-weight:bold; color:#003300; font-size:17px"></td>
          <td width="89%" style="font-weight:bold; color:#003300; font-size:17px"><a href="#">DTR</a></td>
        </tr>
        <tr onClick="loadPayslips();"> 
          <td>&nbsp;</td>
          <td style="font-weight:bold; color:#003300; font-size:17px">&nbsp;</td>
          <td height="30" style="font-weight:bold; color:#003300; font-size:17px"><a href="#">Payslip</a></td>
        </tr>
        <tr onClick="loadInfo('416','1');"> 
          <td height="30">&nbsp;</td>
          <td style="font-weight:bold; color:#003300; font-size:17px"></td>
          <td style="font-weight:bold; color:#003300; font-size:17px"><a href="#">Loans</a></td>
        </tr>
        <tr onClick="loadInfo('415','1');"> 
          <td height="30">&nbsp;</td>
          <td style="font-weight:bold; color:#003300; font-size:17px"><u> </u></td>
          <td style="font-weight:bold; color:#003300; font-size:17px"><a href="#">Misc. Deductions</a></td>
        </tr>
        <tr> 
          <td height="30">&nbsp;</td>
          <td>&nbsp;</td>					
          <td style="font-weight:bold; color:#003300; font-size:15px">
						<a href="#"> </a><br>
					</td>
        </tr>
        <tr> 
          <td height="20">&nbsp;</td>
          <td colspan="2">&nbsp;&nbsp;<font color="#003300"><%//=vSummaryInfo.remove(0)%></font></td>
          </tr>
        <tr>
          <td height="20">&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
      </table>
	  
	    <br>
	   
	</td>
  </tr>
</table>
</body>
</html>
<%
if(dbOP != null)
	dbOP.cleanUP();
%>