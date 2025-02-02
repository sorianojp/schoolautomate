<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {

	if(strAction == 0){			
		if(!confirm("Please confirm to delete material type."))
			return;
		}

	document.form_.page_action.value = strAction;
	
		
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.submit();
}

function ReloadPage(){
	document.form_.submit();
}

function UploadImage(strImageName, strInfoIndex){
	if(strImageName == null || strImageName.length == 0 || strImageName == ""){
		alert("Image information is missing.");
		return;
	}
	
	var sT = "./upload_picture.jsp?image_name="+strImageName+"&opner_form_name=form_&info_index_image="+strInfoIndex;
	var win=window.open(sT,"UploadPicture",'dependent=yes,width=700,height=200,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<%@ page language="java" import="utility.*,lms.Search,java.util.Vector" %>

<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	
	String strInfoIndex = null;
	String strPageAction = null;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-LIBRARY COLLECTION","add_collection_subj_headings.jsp");
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
														"LIB_Cataloging","LIBRARY COLLECTION",request.getRemoteAddr(),
														"add_collection_subj_headings.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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

	Search MTUpdate = new Search(request);	


	Vector vEditInfo  = new Vector();
	Vector vRetResult = new Vector();	

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {		
		strPrepareToEdit = "0";	
		if(MTUpdate.operateOnMaterialType(dbOP,Integer.parseInt(strTemp)) == null)
				strErrMsg = MTUpdate.getErrMsg();			
		else		
			{
				if(strTemp.compareTo("1") == 0)							
					strErrMsg = "Material Type successfully added.";		
				if(strTemp.compareTo("2") == 0)			
					strErrMsg = "Material Type successfully edited.";
				if(strTemp.compareTo("0") == 0)					
					strErrMsg = "Material Type successfully deleted.";
			}
		}	
	
		//search all material
		vRetResult = MTUpdate.operateOnMaterialType(dbOP,4);
		if(vRetResult == null)
			strErrMsg = MTUpdate.getErrMsg();
			
		

if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = MTUpdate.operateOnMaterialType(dbOP,3);
	if(vEditInfo == null)
		strErrMsg = MTUpdate.getErrMsg();
}

%>


<body bgcolor="#F2DFD2">
<form action="./add_material_type.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING - LIBRARY COLLECTION - UPDATE MATERIAL TYPE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="30" colspan="3"><b><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg,"Message: ","","")%></font></b> </td>      
    </tr>
    <tr> 
      <td width="4%" height="30">&nbsp;</td>
	  <td height="30" width="10%">Material Type:</td>
	  <%if(vEditInfo!=null && vEditInfo.size()>0)
	  	strTemp = (String)vEditInfo.elementAt(1);
		else
		strTemp = WI.fillTextValue("material_type");	  
	  %>	
      <td width="96%" height="30">
	  <input type="text" name="material_type" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="50" maxlength="256">
	 </td>		
    </tr>
	
<%if(iAccessLevel > 1) {%>
    <tr> 
      <td height="51"></td>
      <td height="51" colspan="2"><font size="1"> 
       
        <a href='javascript:PageAction(1,"");'><img src="../../images/save_recommend.gif" border="0" name="hide_save"></a> 
        Click to save entries 
      
        <a href="./add_material_type.jsp"><img src="../../images/cancel_recommend.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
    <%}//show only if authorized.%>
  </table>


<%if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#DDDDEE"> 
      <td height="25" colspan="3" class="thinborder"><div align="center"><font color="#FF0000">MATERIAL TYPE LIST</font></div></td>
    </tr>
    <tr> 
      <td width="51%" height="25" class="thinborder"><div align="center"><font size="1"><strong> TYPE </strong></font></div></td>
	  <td width="20%" height="25" class="thinborder"><div align="center"><font size="1"><strong> IMAGE </strong></font></div></td>            
      <td class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 3){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
	  <%
	  strTemp = (String)vRetResult.elementAt(i+2);	  
	  if(strTemp != null && strTemp.length() > 0)
	  	strTemp = "<img src='../../images/"+strTemp+"' height='45' width='45'>";
	  else
	  	strTemp = "<a href=\"javascript:UploadImage('"+(String)vRetResult.elementAt(i+1)+"','"+(String)vRetResult.elementAt(i)+"');\">upload image</a>";
	  %>
	  
	  <td height="25" class="thinborder" align="center"><%=strTemp%></td>      
      <td width="29%" class="thinborder"><div align="center"><font size="1">&nbsp; 
 
       <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete_recommend.gif" width="53" height="26" border="0"></a> 

      </font></div></td>
    </tr>
<%}//for loop%>	
  </table>
<%}%>


<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="material_index" value="" />

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>