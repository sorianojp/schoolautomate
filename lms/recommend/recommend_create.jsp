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
    if(vSetting != null && vSetting.size() > 0) {
      iOnlyForUser    = Integer.parseInt((String)vSetting.elementAt(1));
    }
    if(iOnlyForUser == 1 && (strUserID == null || strUserID.length() == 0) ){ 
      strErrMsg = "User must login to add comment.";
    }
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtComment.operateOnRecommendation(dbOP, request, 1) == null) 
			strErrMsg = mgmtComment.getErrMsg();
		else	
			strErrMsg = "Recommendation is created successfully.";
	}

%>

<body bgcolor="#F2DFD2">
<form action="./recommend_create.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr> 
      <td height="25" colspan="3" bgcolor="#0080C0"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          RECOMMENDATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><font size="3" color="#FF0000">* All fields are must</font></td>
    </tr>
    <%
if(strErrMsg != null) {dbOP.cleanUP();%>
    <tr> 
      <td height="25"><font size="3" color="#FF0000">&nbsp;</font></td>
      <td height="25" colspan="2"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <%return;}
if( strUserID == null || strUserID.length() == 0) {%>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="20%">Name of Person Recommending</td>
      <td width="76%"><input name="PERSON_NAME" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("PERSON_NAME")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Occupation</td>
      <td><input name="OCCUPATION" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("OCCUPATION")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Company/Institution Name</td>
      <td height="25"><input name="COMPANY" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("COMPANY")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      
    <td height="25">Email</td>
      <td height="25"><input name="EMAIL_ADDR" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("EMAIL_ADDR")%>"></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1" color="#0099CC"></td>
    </tr>
    <%}//show only if user is not logged in
%>
    <tr> 
      <td height="25">&nbsp;</td>
      
    <td>Material Type</td>
      <td><select name="MATERIAL_TYPE_INDEX" style="font-size:9px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">
<%=dbOP.loadCombo("material_type_index","MATERIAL_TYPE"," from LMS_MAT_TYPE order by MATERIAL_TYPE_INDEX", 
WI.fillTextValue("MATERIAL_TYPE_INDEX"), false)%>
        </select>
    </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Title</td>
      <td><input name="TITLE" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="32" value="<%=WI.fillTextValue("TITLE")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Author</td>
      <td><input name="AUTHOR" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="255" value="<%=WI.fillTextValue("AUTHOR")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Publisher</td>
      
    <td><input name="PUBLISHER" type="text" size="55" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("PUBLISHER")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Edition/Version</td>
      <td><input name="EDITION" type="text" size="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  maxlength="64" value="<%=WI.fillTextValue("EDITION")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Reason of Recommendation</td>
      <td><textarea name="DESCRIPTION" cols="55" rows="5" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onblur="style.backgroundColor='white'"><%=WI.fillTextValue("DESCRIPTION")%></textarea></td>
    </tr>
    <tr> 
      <td height="58">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td><a href="javascript:PageAction(1)"><img src="../images/save_recommend.gif" border="0"></a><font size="1">click 
        to save entries <font size="1"><a href="./recommend_create.jsp"><img src="../images/cancel_recommend.gif" border="0"></a>click 
        to clearentries </font></font
        ></td>
    </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>