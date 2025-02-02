<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function focusID() {
	document.form_.TOPIC.focus();
}
</script>

<%@ page language="java" import="utility.*,lms.MgmtComment,java.util.Vector" %>
<%
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	Vector vSetting  = null;
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp   = null;
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
	MgmtComment mgmtComment = new MgmtComment();
	vSetting = mgmtComment.saveSetting(dbOP, request, 4);

    int iOnlyForUser    = 0;//anyone can create.
    int iVisibilityStat = 0;//not visibile to all.
    if(vSetting != null && vSetting.size() > 0) {
      iOnlyForUser    = Integer.parseInt((String)vSetting.elementAt(1));
      iVisibilityStat = Integer.parseInt((String)vSetting.elementAt(2));
    }
    if(iOnlyForUser == 1 && (strUserID == null || strUserID.length() == 0) ){ 
      strErrMsg = "User must login to add comment.";
    }
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtComment.operateOnComment(dbOP, request, 1) == null) 
			strErrMsg = mgmtComment.getErrMsg();
		else	
			strErrMsg = "Comments created successfully.";
	}

dbOP.cleanUP();
%>

<body bgcolor="#F2DFD2" onLoad="focusID();">
<form action="./comment_create.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr> 
      <td height="25" colspan="3" bgcolor="#0080C0"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          COMMENTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
<%
if(strErrMsg != null) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><input name="TOPIC" type="text" 
	  style="background-color: '#F2DFD2'; border='0'" readonly="yes"></td>
    </tr>	
<%return;}%>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="20%" height="25">Topic</td>
      <td width="76%" height="25"><input name="TOPIC" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("TOPIC")%>"></td>
    </tr>
<%
if( strUserID == null || strUserID.length() == 0) {%>
   <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Name of Person</td>
      <td height="25"><input name="PERSON_NAME" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("PERSON_NAME")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Occupation/Course</td>
      <td height="25"><input name="OCCUPATION" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("OCCUPATION")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Company Name/School</td>
      <td height="25"><input name="COMPANY" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("COMPANY")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Email Address</td>
      <td height="25"><input name="EMAIL_ADDR" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="32" value="<%=WI.fillTextValue("EMAIL_ADDR")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Postal Address</td>
      <td height="25"><input name="POSTAL_ADDR" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="255" value="<%=WI.fillTextValue("POSTAL_ADDR")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Contact Nos.</td>
      <td height="25"><input name="CONTACT_NO" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("CONTACT_NO")%>"></td>
    </tr>
<%}//show only if user is not logged in.
%>    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Comments</td>
      <td><textarea name="COMMENT" cols="55" rows="5" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onblur="style.backgroundColor='white'"><%=WI.fillTextValue("COMMENT")%></textarea></td>
    </tr>
    <tr> 
      <td height="58">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td><a href="javascript:PageAction(1)">
	  <img src="../images/save_recommend.gif" border="0"></a><font size="1">click 
        to save entries 
		<a href="./comment_create.jsp"><img src="../../images/clear.gif" border="1"></a>
		Click to clear entries</font></td>
    </tr>
    <tr> 
      <td height="58">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
</form>
</body>
</html>
